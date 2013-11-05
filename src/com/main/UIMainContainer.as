package com.main
{
	import com.enum.SkinType;
	import com.enum.TypeEnum;
	import com.events.MainContainerEvent;
	import com.events.SkinEvent;
	import com.events.UIEvent;
	import com.models.CreateUIModel;
	import com.models.ImportConfigs;
	import com.models.SkinModel;
	import com.models.UIInstanceInfo;
	import com.models.ViewBuildParser;
	import com.structurals.StyleData;
	import com.structurals.UIStructural;
	import com.tools.DragCheck;
	import com.undo.AddUIOperation;
	import com.undo.ChangeStyleOperation;
	import com.undo.DelUIOperation;
	import com.undo.LockUIOperation;
	import com.undo.MoveOperation;
	
	import fl.controls.TextInput;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import flashx.undo.IOperation;
	import flashx.undo.UndoManager;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;

	/**
	 * 主容器
	 * 布局啥的都在这个里面写的
	 */
	public class UIMainContainer extends UIComponent
	{
		static private var _instance:UIMainContainer = null;
		/**
		 * 解析数据的模块
		 */
		private var _viewBuildParser:ViewBuildParser = null;
		/**
		 * 默认实例名
		 */
		private var _name:String = "this";
		/**
		 * 所有的容器实例名作为KEY的显示对象
		 */
		private var _displayList:Dictionary = null;
		/**
		 * 用显示对象作为key的数据
		 */
		private var _displayKeyObj:Dictionary = null;
		private var _lastHitDisplayObject:DisplayObject = null;

		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		/**
		 * 右健菜单
		 */
		private var rootMenu:NativeMenu = new NativeMenu;
		/**
		 *
		 */
		private var _defaultFont:TextFormat;


		private var _isShowSelectedFilters:Boolean = true;

		private var _isMoveMainPos:Boolean = false;

		private var _maskDrag:Sprite = new Sprite();
		/**
		 * redo undo 管理器
		 */
		public var undoManager:UndoManager;
		/**
		 * 纪录最后一次移动的对象的起始位置
		 */
		private var _lastUIPosBeforDrag:Point = new Point;
		
		private var _pool:Array;

		public function UIMainContainer()
		{
			super();
			init();
		}

		public function set isMoveMainPos(value:Boolean):void
		{
			_isMoveMainPos = value;
			if (_isMoveMainPos)
			{
				addChildAt(_maskDrag, this.numChildren);
			}
			else
			{
				if (this.contains(_maskDrag) == true)
				{
					removeChild(_maskDrag);
				}
			}
		}
		
		public function reset():void
		{
			this._lastHitDisplayObject = null;
			this._lastUIPosBeforDrag = new Point();
		}

		public function get isMoveMainPos():Boolean
		{
			return _isMoveMainPos;
		}

		public function set defaultFont(value:TextFormat):void
		{
			_defaultFont = value;
			CreateUIModel.Instance.defaultFont = _defaultFont;
		}

		public function get defaultFont():TextFormat
		{
			var f:TextFormat = new TextFormat;
			if (_defaultFont)
			{
				f.align = _defaultFont.align;
				f.blockIndent = _defaultFont.blockIndent;
				f.bold = _defaultFont.bold;
				f.bullet = _defaultFont.bullet;
				f.color = _defaultFont.color;
				f.font = _defaultFont.font;
				f.indent = _defaultFont.indent;
				f.italic = _defaultFont.italic;
				f.leading = _defaultFont.leading;
				f.letterSpacing = _defaultFont.letterSpacing;
				f.size = _defaultFont.size;
			}
			return f;
		}

		/**
		 * 清除所有的UI
		 *
		 */
		public function clear():void
		{
			//初始化 显示列表字典
			_displayList = new Dictionary();
			_displayList[_name] = this;
			//初始化显示对象作为key的字典
			_displayKeyObj = new Dictionary();
			_displayKeyObj[this] = "main";
			while (numChildren)
				removeChildAt(0);
			_lastHitDisplayObject = null;
			_lastUIPosBeforDrag = new Point();
		}

		public function set isShowSelectedFilters(value:Boolean):void
		{
			_isShowSelectedFilters = value;

			var data:UIInstanceInfo = this._displayKeyObj[this._lastHitDisplayObject];
			if (data != null)
			{
				this.setSelectedColor(data);
			}
		}

		public function get isShowSelectedFilters():Boolean
		{
			return _isShowSelectedFilters;
		}

		public static function get Instance():UIMainContainer
		{
			if (null == _instance)
			{
				_instance = new UIMainContainer();
			}
			return _instance;
		}

		public function get displayInfoList():Dictionary
		{
			return this._displayKeyObj;
		}

		public function setTextFormat(value:TextFormat):void
		{
			if (this._lastHitDisplayObject && this._lastHitDisplayObject.hasOwnProperty("setStyle"))
			{

				var targetData:UIInstanceInfo = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
				if(targetData == null) return;
				if (targetData.uiData || targetData.uiData.hasFont == true)
				{
					CreateUIModel.Instance.setUiFont(targetData.infoXML, value);
					this._lastHitDisplayObject["setStyle"]("textFormat", value);
				}
			}
		}

		public function getLastFont():TextFormat
		{
			var tf:TextFormat = null;
			if (_lastHitDisplayObject != null)
				tf = _lastHitDisplayObject["getStyle"]("textFormat");
			if (tf == null)
				tf = _defaultFont;
			return tf;
		}
		
		public var isUndoManagerProcess:Boolean;
		
		public function changeSkin(instance:UIInstanceInfo, styleData:StyleData, skinName:String, type:String, skin:DisplayObject):void
		{
			var display:DisplayObject = instance.displayObj;
			var grid:String = "0-0-0-0";
			var style:String = styleData.skinName;
			var xml:XMLList = instance.infoXML.Styles.style.(@valueName == style);
			
			if (!isUndoManagerProcess)
			{
				var oldSkin:* = display["getStyle"](styleData.skinName);
				var oldSkinName:String = xml.@skinName;
				var oldType:String = xml.@skinType;
				undoManager.pushUndo(new ChangeStyleOperation(instance, styleData, skinName, type, skin, oldSkinName, oldType, oldSkin));
			}
			
			display[styleData.skinMethod](styleData.skinName, skin);
			
			if (type == SkinType.URL_SKIN)
				skinName = SkinModel.Instance.getURLComparativelyPath(skinName);
			xml.@skinName = skinName;
			xml.@grid = grid;
			xml.@skinType = type;
			CreateUIModel.Instance.update();
		}
		
		public function appendUI(child:UIInstanceInfo):void
		{
			this._displayList[child.instanceName] = child.displayObj;
			this._displayKeyObj[child.displayObj] = child;
			
			var parent:DisplayObjectContainer = findParent(child.parentName);
			if (parent != this)
			{
				var parentData:UIInstanceInfo = this._displayKeyObj[parent] as UIInstanceInfo;
				if (parentData.uiData.addFunName.indexOf("set") != -1)
				{
					parent[parentData.uiData.addFunName.split("|")[1]] = (child.displayObj);
				}
				else if (parentData.uiData.addFunName.indexOf("fun") != -1)
				{
					parent[parentData.uiData.addFunName.split("|")[1]](child.displayObj);
				}
			}
			else
			{
				parent.addChild(child.displayObj);
			}
			
			child.updateView();
			child.locked = true;
			CreateUIModel.Instance.code.childRen.appendChild(child.infoXML);
			this.dispatchEvent(new MainContainerEvent(MainContainerEvent.UPDATE_INSTANCE_LIST));
		}

		/**
		 * 创建一个UI
		 */
		public function addUI(value:UIStructural, parentName:String, instanceName:String = null):UIInstanceInfo
		{
			var child:UIInstanceInfo = null;
			//创建数据
			var xml:XML = CreateUIModel.Instance.parseAndBuildCode(value, parentName, instanceName);
			if (xml != null)
			{
				child = createUI(xml);
				child.uiData = value;
				
				if (value.hasFont)
				{
					child.displayObj["setStyle"]("textFormat", this._defaultFont);
				}
				appendUI(child);
			}
			
			pushUndo(new AddUIOperation(child));
			return child;
		}

		private function findParent(parentName:String):DisplayObjectContainer
		{
			return _displayList[parentName] as DisplayObjectContainer;
		}

		/**
		 * 创建UI
		 */
		private function createUI(xml:XML):UIInstanceInfo
		{
			return _viewBuildParser.parseUI(xml);
		}

		private function init():void
		{
			this.name = _name;
			//ui解析XML的对象
			_viewBuildParser = new ViewBuildParser();

			//CreateUIModel.Instance.code.@instanceName = this._name;

			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
			initMenu();

			_maskDrag.graphics.beginFill(0x000000, 0.5);
			_maskDrag.graphics.drawRect(0, 0, 1000, 600);
			_maskDrag.graphics.endFill();
			
			_pool = new Array();
			
			this.addChild(SetFontSettingPanel.Instance);
			SetFontSettingPanel.Instance.visible = false;
		}

		private function initMenu():void
		{
			addMenuItem("移动至上一层", rootMenu);
			addMenuItem("移动至下一层", rootMenu);
			addMenuItem("设置皮肤", rootMenu);
			addMenuItem("设置外部皮肤", rootMenu);
			addMenuItem("删除", rootMenu);
			addMenuItem("设置字体", rootMenu);
			addMenuItem("锁定当前UI", rootMenu);
			addMenuItem("复制", rootMenu);
			this.contextMenu = rootMenu;
		}

		private function addMenuItem(label:String, menu:NativeMenu, data:Object = null):NativeMenuItem
		{
			var item:NativeMenuItem = new NativeMenuItem(label);
			item.data = data;
			item.addEventListener(Event.SELECT, onMenuSelectedHandler);
			menu.addItem(item);
			return item;
		}

		private function addSubMenuItem(label:String, menu:NativeMenu, data:Object = null):NativeMenuItem
		{
			var item:NativeMenuItem = new NativeMenuItem(label);
			item.data = data;
			item.addEventListener(Event.SELECT, onStyleSubMenuSelectedHandler);
			menu.addItem(item);
			return item;
		}

		private function onStyleSubMenuSelectedHandler(evt:Event):void
		{
			itemSelected(evt.target as NativeMenuItem);
		}
		
		private function itemSelected(item:NativeMenuItem):void
		{
			var data:StyleData = item.data.data;
			var arr:Array = data.skinName.split("|")
			if(arr.length > 1)
			{
				if(item.menu != this._subStyleMenuSWF)
				{
					for(var i:int=0;i<arr.length;i++)
					{
						_pool.push(findItemByName(arr[i]));
					}
				}
				next();
				return;
			}
			
			if (item.data.data.type != TypeEnum.font && item.data.data.type != TypeEnum.displayObject && item.data.data.type != TypeEnum.cls)
			{
				OtherStyleSettingPanel.Instance.showPanel(item.data.data as StyleData, item.data.xmlData as XML, this._lastHitDisplayObject);
			}
			else if (item.data.data.type == TypeEnum.font)
			{
				SetFontSettingPanel.Instance.showPanel(item.data.data as StyleData, item.data.xmlData as XML, this._lastHitDisplayObject);
			}
			else
			{
				var type:String = SkinType.SWF_SKIN;
				if (item.menu == this._subStyleMenuSWF)
				{
					type = SkinType.SWF_SKIN;
				}
				else
				{
					type = SkinType.URL_SKIN;
				}
				
				var e:SkinEvent = new SkinEvent(SkinEvent.SELECT_SWF_SKIN);
				e.styleData = item.data.data as StyleData;
				e.xml = item.data.xmlData as XML;
				e.display = _lastHitDisplayObject;
				e.skinType = type;
				e.instance = _displayKeyObj[_lastHitDisplayObject];
				dispatchEvent(e);
			}
		}
		
		private function findItemByName(type:String):NativeMenuItem
		{
			for each(var item:NativeMenuItem in _subStyleMenuURL.items)
			{
				if(item.data.data.skinName == type)
				{
					return item;
				}
			}
			return null;
		}
		
		public function next():Boolean
		{
			var item:NativeMenuItem = _pool.shift();
			if(item != null)
			{
				setTimeout(sendEvent,100,item);
				return true;
			}
			return false;
		}
		
		private function sendEvent(item:EventDispatcher):void
		{
			item.dispatchEvent(new Event(Event.SELECT));
		}
		
		private function onMenuSelectedHandler(evt:Event):void
		{
			if (_lastHitDisplayObject == null)
				return;
			var item:NativeMenuItem = evt.target as NativeMenuItem;
			var index:int = rootMenu.getItemIndex(item);
			var data:UIInstanceInfo = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
			switch (index)
			{
				case 0: //移动至上一层
					changeLayer(_lastHitDisplayObject, true);
					break;
				case 1: //移动至下一层
					changeLayer(_lastHitDisplayObject, false);
					break;
				case 2: //设置皮肤
					break;
				case 3: //设置外部皮肤
					break;
				case 4: //删除
					Alert.show("是否删除当前UI", "警告", 3, null, deleteUIAlertHandler);
					break;
				case 5: //字体
					this.dispatchEvent(new Event(Event.SELECT));
					break;
				case 6: //锁定	
					lockedUI();
					break;
				case 7: //复制
					if (data.infoXML.childRen.ui.length() == 0)
					{
						var mainEvent:MainContainerEvent = new MainContainerEvent(MainContainerEvent.COPY_UI);
						mainEvent.copyUIData = data;
						data.locked = true;
						this.dispatchEvent(mainEvent);
					}
					else
					{
						Alert.show("容器中有其它子对象所以无法复制，请先移除");
					}
					break;
			}

		}

		public function copyUI(value:UIInstanceInfo, parentName:String, instanceName:String = null):void
		{
			instanceName = CreateUIModel.Instance.checkName(instanceName);
			if (instanceName != null)
			{
				var copyXML:XML = value.infoXML.copy();
				copyXML.@instanceName = instanceName;
				copyXML.@parentName = this._name;
				ImportConfigs.Instance.createUI(copyXML, CreateUIModel.Instance.code).locked = false;
			}
		}

		private function lockedUI():void
		{
			if (this._lastHitDisplayObject != null)
			{
				var data:UIInstanceInfo = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
				lockUI(data);
				
				pushUndo(new LockUIOperation(data));
			}
		}

		/**
		 * 锁定一个UI操作
		 * @param data
		 *
		 */
		public function lockUI(data:UIInstanceInfo):void
		{
			data.locked = !data.locked;
			setSelectedColor(data);
		}

		private function get currentUIInfo():UIInstanceInfo
		{
			return this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
		}


		private var _subStyleMenuSWF:NativeMenu = null;
		private var _subStyleMenuURL:NativeMenu = null;
		
		private function updateStylesList(value:Array, xml:XML):void
		{
			_subStyleMenuSWF = new NativeMenu();
			_subStyleMenuURL = new NativeMenu();
			var menu0:NativeMenuItem = rootMenu.getItemAt(2);
			var menu1:NativeMenuItem = rootMenu.getItemAt(3);
			var i:int = 0;
			var len:int = value.length;
			for (i = 0; i < len; i++)
			{
				var styleData:StyleData = value[i] as StyleData;
				var obj:Object = {data: styleData, xmlData: xml};
				addSubMenuItem(styleData.describe, _subStyleMenuSWF, obj);
				addSubMenuItem(styleData.describe, _subStyleMenuURL, obj)
			}
			menu0.submenu = _subStyleMenuSWF;
			menu1.submenu = _subStyleMenuURL;
		}

		private function changeLayer(theTarget:DisplayObject, isNext:Boolean):void
		{
			var changed:Boolean = true;
			var index:int = 0;
			var parent:DisplayObjectContainer = theTarget.parent;
			var targetIndex:int = parent.getChildIndex(theTarget);
			index = isNext ? (targetIndex + 1) : (targetIndex - 1);
			if (index == -1)
			{
				index = 0;
				changed = false;
			}
			else if (index > (parent.numChildren - 1))
			{
				index = parent.numChildren - 1;
				changed = false;
			}
			if (changed)
			{
				var swapData:UIInstanceInfo = this._displayKeyObj[parent.getChildAt(index)] as UIInstanceInfo;
				//parent.addChildAt(theTarget, index);
				var targetData:UIInstanceInfo = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;

				var childXML:XML = CreateUIModel.Instance.swapIndex(targetData.infoXML, swapData.infoXML, isNext);
				var i:int = 0;
				var len:int = childXML.ui.length();
				var tempTheDisplayObjects:Array = [];
				for (i = 0; i < len; i++)
				{
					var instanceName:String = childXML.ui[i].@instanceName.toString();
					var childs:DisplayObject = this._displayList[instanceName] as DisplayObject
					tempTheDisplayObjects.push(parent.removeChild(childs));
				}

				var theDisplayObject:DisplayObject = null;
				for each (theDisplayObject in tempTheDisplayObjects)
				{
					parent.addChild(theDisplayObject);
				}

			}
		}



		private function onAddToStageHandler(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStageHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDownHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
		}


		private function onKeyUpHandler(evt:KeyboardEvent):void
		{
			if (this._lastHitDisplayObject != null && this._lastHitDisplayObject.parent != null)
			{
				/*if(stage.focus is TextField)
				{
					
				}
				else
				{
					stage.focus = stage;
				}*/
				

				switch (evt.keyCode)
				{
					case 112:
						lockedUI();
						break;
					case 113:
						this.dispatchEvent(new Event(Event.SELECT));
						break;
					case 114: //移动至上一层
						changeLayer(_lastHitDisplayObject, true);
						break;
					case 115: //移动至下一层
						changeLayer(_lastHitDisplayObject, false);
						break;
					case 116:
						rootMenu.display(this.stage, this.stage.mouseX, this.stage.mouseY);
						break;
					case 118:
						//SkinPanel.Instance.visible = false;
						break;
					case 117:
						if (currentUIInfo != null)
						{
							currentUIInfo.layerLocked = !currentUIInfo.layerLocked;
							setSelectedColor(currentUIInfo);
						}
						break;
				}
			}
		}

		private function onKeyDownHandler(evt:KeyboardEvent):void
		{
			if (this._lastHitDisplayObject != null && this._lastHitDisplayObject.parent != null)
			{
				var lastData:UIInstanceInfo = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
				
				if (lastData.locked && (evt.keyCode == 38 || evt.keyCode == 40 || evt.keyCode == 37 || evt.keyCode == 39))
				{
					//Alert.show("对象已经锁定，请解所锁", "警告");
					return;
				}
				
				switch (evt.keyCode)
				{
					case 46:
						Alert.show("是否删除当前UI", "警告", 3, null, deleteUIAlertHandler);
						break;
					case 38: //SHANG 
						_lastHitDisplayObject.y--;
						updateXYProperty();
						break;
					case 40: //XIA 
						_lastHitDisplayObject.y++;
						updateXYProperty();
						break;
					case 37: //ZUO
						_lastHitDisplayObject.x--;
						updateXYProperty();
						break;
					case 39: //YOU
						_lastHitDisplayObject.x++;
						updateXYProperty();
						break;
				}
			}
		}

		private function pushUndo(op:IOperation):void
		{
			if (!isUndoManagerProcess)
				undoManager.pushUndo(op);
		}
		/**
		 * 删除一个UI
		 * @param traget
		 * @param checkLock
		 *
		 */
		public function deleteUI(data:UIInstanceInfo, checkLock:Boolean = true):void
		{
			if (!checkLock || !data.locked)
			{
				data.locked = false;
				var target:DisplayObject = data.displayObj;
				
				pushUndo(new DelUIOperation(data));
				
				target.parent.removeChild(target);
				CreateUIModel.Instance.removeChildXML(data.infoXML);
				CreateUIModel.Instance.removeName(data.instanceName);
				this._displayList[data.instanceName] = null;
				delete this._displayList[data.instanceName];
				this._displayKeyObj[data.displayObj] = null;
				delete this._displayKeyObj[data.displayObj];
				this.dispatchEvent(new MainContainerEvent(MainContainerEvent.UPDATE_INSTANCE_LIST));
			}
			else
			{
				Alert.show("先解除锁定再删除");
			}
		}

		private function deleteUIAlertHandler(event:CloseEvent = null):void
		{
			if (event == null || event.detail == Alert.YES)
			{
				var data:UIInstanceInfo = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
				deleteUI(data);
			}
		}

		private function onMouseMoveMainHandler(evt:MouseEvent):void
		{
			this.x = this.parent.mouseX - _offsetX;
			this.y = this.parent.mouseY - _offsetY;
		}

		private function onMouseUpMainHandler(evt:MouseEvent):void
		{

			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveMainHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpMainHandler);

			this.dispatchEvent(new UIEvent(UIEvent.MAIN_MOVED))

		}

		private function onStageMouseDownHandler(evt:MouseEvent):void
		{
			if (_isMoveMainPos && evt.target == _maskDrag)
			{
				_offsetX = this.mouseX * this.scaleX;
				_offsetY = this.mouseY * this.scaleY;
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveMainHandler);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpMainHandler);
				return;
			}
			var uiTarget:DisplayObject = evt.target as DisplayObject;

			try
			{
				var uiData:UIInstanceInfo = _displayKeyObj[uiTarget];
			}
			catch (e:Error)
			{
				return;
			}
			if (evt.target == this)
			{
				return;
			}
			if (uiData == null)
			{
				var isFind:Boolean = false;
				var parent:DisplayObject = uiTarget;

				while (!isFind)
				{
					if (parent == null)
					{
						return;
					}
					else if (_displayKeyObj[parent] as UIInstanceInfo != null || parent == this)
					{
						isFind = true;
						uiTarget = parent;
						uiData = _displayKeyObj[parent] as UIInstanceInfo;
						break;
					}
					else
					{
						parent = parent.parent;
					}
				}
			}

			if (uiData != null)
				setSelectUI(uiData);
		}


		public function setSelectUI(uiData:UIInstanceInfo):void
		{
			var uiTarget:DisplayObject = uiData.displayObj;
			
			_offsetX = uiTarget.mouseX;
			_offsetY = uiTarget.mouseY;
			
			if (_lastHitDisplayObject != null)
			{
				_lastHitDisplayObject.filters = [];
			}
			_lastHitDisplayObject = uiTarget;
			//纪录
			_lastUIPosBeforDrag.x = _lastHitDisplayObject.x;
			_lastUIPosBeforDrag.y = _lastHitDisplayObject.y;
			
			updateStylesList(uiData.uiData.styleList, uiData.infoXML);
			
			setSelectedColor(uiData);
			
			if (!uiData.locked)
			{
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			}
			
			var event:UIEvent = new UIEvent(UIEvent.SELECTED_UI);
			event.selectedUi = _lastHitDisplayObject;
			event.data = uiData;
			this.dispatchEvent(event);
		}

		private function setSelectedColor(data:UIInstanceInfo):void
		{
			var color:uint = data.locked ? 0xFF00FF : 0x0fffff;

			if (data.layerLocked == true)
			{
				if (data.locked)
				{
					color = 0x8000ff;
				}
				else
				{
					color = 0xffff00;
				}
			}
			var glow:GlowFilter = new GlowFilter(color, 1, 2, 2, 10, 1);

			_lastHitDisplayObject.filters = [glow];

			if (_isShowSelectedFilters != true)
			{
				_lastHitDisplayObject.filters = [];
			}
			if(stage.focus is TextField)
			{
				
			}
			else
			{
				stage.focus = stage;
			}
		}

		private function onMouseMoveHandler(evt:MouseEvent):void
		{

			var data:UIInstanceInfo = _displayKeyObj[this._lastHitDisplayObject];
			if (data.locked && this.stage.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			}
			if (data != null)
			{
				if (data.locked)
				{
					return;
				}

				if (null != _lastHitDisplayObject)
				{
					if (_lastHitDisplayObject.parent != this)
					{
						if (currentUIInfo.layerLocked == false)
						{
							if (_lastHitDisplayObject.parent != null)
							{
								_lastHitDisplayObject.parent.removeChild(_lastHitDisplayObject);
							}
							this.addChild(_lastHitDisplayObject);
						}
					}
					evt.updateAfterEvent();

					updatePos(data);
				}
			}
		}

		private function onMouseUpHandler(evt:MouseEvent):void
		{

			if (currentUIInfo.layerLocked == true)
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
				return;
			}

			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			var lastData:UIInstanceInfo = null;
			if (_lastHitDisplayObject != null && _lastHitDisplayObject.parent != null)
			{
				var dis:DisplayObject = DragCheck.checkContainer(this, this._lastHitDisplayObject);

				var data:UIInstanceInfo = this._displayKeyObj[dis] as UIInstanceInfo;

				pushUndo(new MoveOperation(_displayKeyObj[_lastHitDisplayObject], _lastUIPosBeforDrag.clone(), new Point(_lastHitDisplayObject.x, _lastHitDisplayObject.y)));

				if ((this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo).locked)
				{
					return;
				}

				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
				if (dis == this)
				{
					if (this._lastHitDisplayObject.parent != this)
					{
						addChild(this._lastHitDisplayObject);
					}
				}
				else if (data != null && data.isContainer == false && data.locked == false)
				{
					addChild(this._lastHitDisplayObject);
					lastData = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
					CreateUIModel.Instance.moveTo(lastData.infoXML, CreateUIModel.Instance.code);
				}
				else if (data != null)
				{
					if (data.isContainer == true && data.locked)
					{
						lastData = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
						CreateUIModel.Instance.moveTo(lastData.infoXML, CreateUIModel.Instance.code);
					}
					else if (data.isContainer == true && !data.locked)
					{
						lastData = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
						if (checkChildInPanel(data.displayObj as DisplayObjectContainer, data.infoXML, lastData.infoXML) != true)
						{
							if (data.uiData.addFunName.indexOf("set") != -1)
							{
								(dis as DisplayObjectContainer)[data.uiData.addFunName.split("|")[1]] = (this._lastHitDisplayObject);
							}
							else if (data.uiData.addFunName.indexOf("fun") != -1)
							{
								(dis as DisplayObjectContainer)[data.uiData.addFunName.split("|")[1]](this._lastHitDisplayObject);
							}
							if (data.autoLayOut != true)
							{
								this._lastHitDisplayObject.x = (dis as DisplayObjectContainer).mouseX;
								this._lastHitDisplayObject.y = (dis as DisplayObjectContainer).mouseY;
								updatePos(lastData);
							}
							else
							{
								updateXYProperty();
							}
							if (this._lastHitDisplayObject.parent != this)
							{
								var parentData:UIInstanceInfo = this._displayKeyObj[dis] as UIInstanceInfo;
								CreateUIModel.Instance.moveTo(lastData.infoXML, parentData.infoXML);
							}
						}
						else
						{
							addChild(this._lastHitDisplayObject);
							lastData = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
							CreateUIModel.Instance.moveTo(lastData.infoXML, CreateUIModel.Instance.code);
							Alert.show("此容器只允许设置一个子对象，请先移出一个");
						}
					}
				}
				else if (this._lastHitDisplayObject.parent == this)
				{
					lastData = this._displayKeyObj[_lastHitDisplayObject] as UIInstanceInfo;
					CreateUIModel.Instance.moveTo(lastData.infoXML, CreateUIModel.Instance.code);
				}
			}
			CreateUIModel.Instance.update();
		}

		private function checkChildInPanel(panent:DisplayObjectContainer, parentData:XML, targetData:XML):Boolean
		{
			var result:Boolean = false;
			var childNum:int = parentData.childRen.ui.length();
			var data:UIInstanceInfo = this._displayKeyObj[panent] as UIInstanceInfo;
			if (childNum >= 1 && data.uiData.singlenChild == true)
			{
				result = true;
			}
			if (childNum != 0 && parentData.childRen.ui[0].@instanceName == targetData.@instanceName)
			{
				result = false;
			}
			return result;
		}

		private function updatePos(data:UIInstanceInfo):void
		{
			_lastHitDisplayObject.x = this._lastHitDisplayObject.parent.mouseX - _offsetX;
			_lastHitDisplayObject.y = this._lastHitDisplayObject.parent.mouseY - _offsetY;
			updateXYProperty();
		}
		public function changeWH(uiInstance:UIInstanceInfo,width:Number, height:Number):void
		{
			uiInstance.displayObj["width"] = width;
			uiInstance.displayObj["height"] = height;
			updateXYProperty();
		}
		
		private function updateXYProperty():void
		{
			var evt:UIEvent = new UIEvent(UIEvent.ATTRIBUTE_CHANGE);
			this.dispatchEvent(evt);
		}

		/**
		 * 点击的一个对象
		 */
		public function get lastHitDisplayObject():DisplayObject
		{
			return _lastHitDisplayObject;
		}

		public function set lastHitDisplayObject(value:DisplayObject):void
		{
			_lastHitDisplayObject = value;
		}


	}
}