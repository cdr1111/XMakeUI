package com.models
{
	import com.enum.SkinType;
	import com.enum.TypeEnum;
	import com.main.UIMainContainer;
	import com.structurals.UIStructural;
	import com.tools.TypeConversion;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.text.TextFormat;

	/**
	 * 反导入
	 */
	public class ImportConfigs extends EventDispatcher
	{
		private static var _instance:ImportConfigs = null;
		private var _xml:XML = null;
		private var _codeXML:XML = null;
		private var _uiconfigs:Array = null;
		private var _createBox:Array = [];

		public function ImportConfigs(target:IEventDispatcher = null)
		{
			super(target);
		}

		public static function get Instance():ImportConfigs
		{
			if (null == _instance)
			{
				_instance = new ImportConfigs();
			}
			return _instance;
		}

		public function set uiconfigs(v:Array):void
		{
			_uiconfigs = v;
		}

		public function setSonfig(xml:XML):void
		{
			_xml = xml;
			_codeXML = CreateUIModel.Instance.code;
			_createBox = [];
			parseXML();
			updateXML();
			CreateUIModel.Instance.update();
		}

		private function updateXML():void
		{
			var i:int = 0;
			var len:int = _createBox.length;
			var ui:UIInstanceInfo = null;
			for (i = 0; i < len; i++)
			{
				ui = _createBox[i] as UIInstanceInfo;
				if (ui.parentName != ui.infoXML.parent().parent().@instanceName.toString())
				{
					var xml:XML = findXML(ui.parentName);
					CreateUIModel.Instance.moveTo(ui.infoXML, xml);
				}
			}


		}


		private function findXML(name:String):XML
		{
			var i:int = 0;
			var len:int = _createBox.length;
			var ui:UIInstanceInfo = null;
			var xml:XML = null;
			for (i = 0; i < len; i++)
			{
				ui = _createBox[i] as UIInstanceInfo;
				if (ui.instanceName == name)
				{
					xml = ui.infoXML;
					break;
				}
			}
			return xml;
		}


		private function parseXML():void
		{
			if (_codeXML.@ClassName.toString() == "")
			{
				_codeXML.@instanceName = _xml.@instanceName;
				_codeXML.@PackageName = _xml.@PackageName;
				_codeXML.@ClassName = _xml.@ClassName;
				_codeXML.@ClassDesc = _xml.@ClassDesc;
				_codeXML.@defaultFont = _xml.@defaultFont;
				BuildCoder.Instance.ClassName = _codeXML.@ClassName.toString();
				BuildCoder.Instance.ClassDesc = _codeXML.@ClassDesc.toString();
				BuildCoder.Instance.PackageName = _codeXML.@PackageName.toString();
				UIMainContainer.Instance.defaultFont = getTextFomatByConfig(_codeXML.@defaultFont.toString());
			}
			parseChild();
		}


		public function parseChild():void
		{
			var i:int = 0;
			var len:int = _xml.childRen.ui.length();
			for (i = 0; i < len; i++)
			{
				parseUi(_xml.childRen.ui[i]);
			}
		}

		private function parseUi(xml:XML):void
		{
			createUI(xml, xml.parent().parent());
			if (_uiInstanceInfo != null)
			{
				var i:int = 0;
				var len:int = xml.childRen.ui.length();
				for (i = 0; i < len; i++)
				{
					parseUi(xml.childRen.ui[i]);
				}
			}
		}

		private var _uiInstanceInfo:UIInstanceInfo = null;

		public function createUI(xml:XML, parent:XML):UIInstanceInfo
		{
			var s:UIStructural = searchUIData(xml.@fullName.toString());
			_uiInstanceInfo = UIMainContainer.Instance.addUI(s, xml.@parentName, xml.@instanceName);
			if (_uiInstanceInfo != null)
			{
				_createBox.push(_uiInstanceInfo);
				updatePropertie(_uiInstanceInfo, xml);
				updateStyles(_uiInstanceInfo, xml);
				
				var fontValue:String = xml.@font.toString();
				if (fontValue == "defaultFont")
				{
					_uiInstanceInfo.displayObj["setStyle"]("textFormat", UIMainContainer.Instance.defaultFont);
				}
				else if (fontValue != null && fontValue != "" && fontValue.length > 5)
				{
					_uiInstanceInfo.displayObj["setStyle"]("textFormat", getTextFomatByConfig(fontValue));
				}
				else
				{
					return _uiInstanceInfo;
				}
				_uiInstanceInfo.infoXML.@font = fontValue;
			}
			return _uiInstanceInfo;
		}

		private function updateStyles(data:UIInstanceInfo, xml:XML):void
		{
			var i:int = 0;
			var len:int = xml.Styles.style.length();
			for (i = 0; i < len; i++)
			{
				var skinXML:XML = xml.Styles.style[i];
				var styleName:String = skinXML.@valueName.toString();
				var styleType:String = skinXML.@skinType.toString();
				var styleGrid:String = skinXML.@grid.toString();
				var skinName:String = skinXML.@skinName.toString();
				var skinMethodName:String = skinXML.@skinMethod.toString();
				var skinType:String = skinXML.@type;
				if (skinName != null && skinName != "none")
				{
					//data.infoXML.Styles.style[i];
					var styleXML:Object = data.infoXML.Styles.style[i].(@valueName == styleName);
					styleXML.@valueName = styleName;
					styleXML.@skinType = styleType;
					styleXML.@grid = styleGrid;
					styleXML.@skinName = skinName;
					styleXML.@type = skinType;

					if (styleType == SkinType.SWF_SKIN)
					{
						if (skinType == TypeEnum.cls)
						{
							data.displayObj[skinMethodName](styleName, SkinModel.Instance.getClsByClassName(skinName));
						}
						else
						{
							var skinObj:DisplayObject = new (SkinModel.Instance.getClsByClassName(skinName) as Class)();
							data.displayObj[skinMethodName](styleName, skinObj);
						}
					}
					else if (styleType == SkinType.URL_SKIN)
					{
						var skinLoader:SkinLoader = new SkinLoader(data);
						skinLoader.skinMethodName = skinMethodName;
						skinLoader.skinName = skinName;
						skinLoader.styleGrid = styleGrid;
						skinLoader.styleName = styleName;
						skinLoader.addEventListener(Event.COMPLETE, onCompleteHandler);

						var urlData:Array = skinLoader.skinName.split("%");

						var url:String = UIParser.Instance.resource_URL + urlData[1] + "/" + urlData[0];
						skinLoader.loadSkin(url);
					}
					else
					{
						data.displayObj[skinMethodName](styleName, TypeConversion.convert(skinName, styleType));
					}
				}
			}
		}

		private function onCompleteHandler(evt:Event):void
		{
			var load:SkinLoader = evt.target as SkinLoader;

			var data:UIInstanceInfo = load.data;

			var theDisplayObject:DisplayObject = data.displayObj;

			var skin:DisplayObject = load.loaderContent;

			theDisplayObject["setStyle"](load.styleName, skin);

			load.removeEventListener(Event.COMPLETE, onCompleteHandler);
			load.dispose();
		}


		private function updatePropertie(data:UIInstanceInfo, xml:XML):void
		{
			var i:int = 0;
			var len:int = xml.Properties.Propertie.length();
			for (i = 0; i < len; i++)
			{
				var methodName:String = xml.Properties.Propertie[i].@name.toString();
				var valueObj:String = xml.Properties.Propertie[i].@value.toString();
				var type:String = xml.Properties.Propertie[i].@type.toString();

				if (valueObj == "")
				{
					if (type == TypeEnum.int || type == TypeEnum.number || type == TypeEnum.uint)
					{
						data.displayObj[methodName] = null;
					}
					else
					{
						data.displayObj[methodName] = TypeConversion.convert(valueObj, type);
					}
				}
				else
				{
					data.displayObj[methodName] = TypeConversion.convert(valueObj, type);
				}
				data.infoXML.Properties.Propertie.(@name == methodName).@value = valueObj;
			}
		}


		private function searchUIData(name:String):UIStructural
		{
			var obj:Object = null;
			var data:UIStructural = null;
			for each (obj in _uiconfigs)
			{
				if (obj.data.uiName == name)
				{
					data = obj.data as UIStructural;
					break;
				}
			}
			return data;
		}

		private function getTextFomatByConfig(value:String):TextFormat
		{
			var tf:TextFormat = TypeConversion.convert(value, TypeEnum.font);/*= new TextFormat();
			var fonts:Array = value.split("|");
			if (fonts.length > 1)
			{
				tf.align = String(fonts[0]);
				tf.bold = fonts[1] == "true";
				tf.color = uint(fonts[2]);
				tf.font = String(fonts[3]);
				tf.size = uint(fonts[4]);
				if (fonts.length >= 6)
				{
					tf.italic = fonts[5] == "true";
					tf.leading = uint(fonts[6]);
					tf.underline = fonts[7] == "true";
					tf.letterSpacing = uint(fonts[8]);
				}
			}
			else
				tf = UIMainContainer.Instance.defaultFont;*/
			return tf;
		}
	}
}