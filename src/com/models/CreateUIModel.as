package com.models
{
	import com.events.UIEvent;
	import com.structurals.AttributeStructural;
	import com.structurals.StyleData;
	import com.structurals.UIStructural;
	import com.tools.XMLTool;
	
	import flash.events.EventDispatcher;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;

	/**
	 * 生成保存用的XML
	 */
	public class CreateUIModel extends EventDispatcher
	{
		static private var _instance:CreateUIModel = null;
		/**
		 *	缓存名字
		 */
		private var _nameDic:Dictionary = null;
		/**
		 *
		 */
		private var _codeXML:XML = null;

		public function CreateUIModel()
		{
		}

		public function set defaultFont(value:TextFormat):void
		{
			_codeXML.@defaultFont = getTextFormatToString(value);
			update();
		}

		public function update():void
		{
			var event:UIEvent = new UIEvent(UIEvent.UPDATE_CODE);
			this.dispatchEvent(event);
		}

		public function removeChildXML(xml:XML):void
		{
			var parentXML:XML = xml.parent();
			parentXML.replace(xml.childIndex(), "");
			update();
		}

		public function setUiFont(target:XML, value:TextFormat):void
		{
			target.@font = getTextFormatToString(value);
			//.align + "|" + value.bold + "|" + value.color + "|" 
			//+ value.font + "|" + value.size + "|" + value.italic + "|" + value.leading + "|" + value.letterSpacing + "|" + value.underline;
			this.update();
		}

		private function getTextFormatToString(value:TextFormat):String
		{
			var font:String = null;
			if (value.italic != null && value.leading != null && value.underline != null && value.letterSpacing != null)
			{
				font = value.align + "|" + value.bold + "|" + value.color + "|" + value.font + "|" + value.size + "|" + value.italic + "|" + value.leading + "|" + value.letterSpacing + "|" + value.underline;
			}
			else
			{
				font = value.align + "|" + value.bold + "|" + value.color + "|" + value.font + "|" + value.size;
			}
			return font;
		}

		public function moveTo(target:XML, moveToParentXML:XML):void
		{
			var parentXML:XML = target.parent();
			parentXML.replace(target.childIndex(), "");
			moveToParentXML.childRen.appendChild(target);
			target.@parentName = target.parent().parent().@instanceName;
			update();
		}

		public function swapIndex(target:XML, changeXML:XML, isBefore:Boolean):XML
		{
			//父级 XML
			var parentXML:XML = target.parent();
			//旧  XML索引
			var oldIndex:int = target.childIndex();
			//将老的移除掉
			parentXML.replace(oldIndex, "");

			var name:String = target.name().toString();
			var changeIndex:int = changeXML.childIndex();
			var swapXML:XML = parentXML[name][changeIndex];
			if (isBefore)
			{
				parentXML.insertChildAfter(changeXML, target);
			}
			else
			{
				parentXML.insertChildBefore(changeXML, target);
			}
			/*var i:int = 0;
			   var len:int = parentXML.ui.length();
			   for(i = 0; i < len; i++)
			   {
			   trace(parentXML.ui[i].@instanceName)
			 }*/
			update();
			return parentXML;
		}


		public function get code():XML
		{
			return _codeXML;
		}

		public static function get Instance():CreateUIModel
		{
			if (null == _instance)
			{
				_instance = new CreateUIModel();
			}
			return _instance;
		}

		public function checkName(instanceName:String):String
		{
			/*if (instanceName.length < 3)
			{
				Alert.show("实例名字不得小于3个字符", "提示：");
				return null;
			}*/
			if (instanceName.charAt(0) != "_")
			{
				instanceName = "_" + instanceName;
			}
			//检测实例名字是否有重复
			if (_nameDic[instanceName] != null || _nameDic[instanceName] == instanceName)
			{
				//实例名重复
				Alert.show("已经有了同名的实例名存在", "提示：");
				return null;
			}
			else if (instanceName.search(/[^a-zA-Z_0-9]/gi) != -1)
			{
				// 名字中有不规范的地方
				Alert.show("请使用 a-z A-z _ 命名规范", "提示：");
				return null;
			}
			return instanceName;
		}


		/**
		 * 把数据换成生成用的XML
		 */
		public function parseAndBuildCode(value:UIStructural, parentName:String, instanceName:String = null):XML
		{
			if (null == instanceName)
			{
				instanceName = saveRandomInstanceName(value.uiName);
			}
			else
			{
				instanceName = checkName(instanceName);
				if (instanceName == null)
				{
					return null;
				}
				else
				{
					_nameDic[instanceName] = instanceName;
				}
			}
			var childXML:XML = new XML(createCode(value, instanceName, parentName));
			return childXML;
		}

		/**
		 * 重置 
		 * 
		 */		
		public function reset():void
		{
			_nameDic = new Dictionary();
			_codeXML = new XML("<root> </root>");
			_codeXML.@instanceName = "this";
			var childRen:XMLTool = new XMLTool("childRen");
			_codeXML.appendChild(XMLList(childRen.toString()));
		}
		
		private function createCode(value:UIStructural, instanceName:String, parentName:String):String
		{
			var xml:XMLTool = new XMLTool("ui");
			xml.addPropertie("fullName", value.uiName);
			xml.addPropertie("instanceName", instanceName);
			xml.addPropertie("isContainer", value.isContainer.toString());
			xml.addPropertie("parentName", parentName)
			xml.addPropertie("autoLayOut", value.autoLayOut.toString());
			xml.addPropertie("addFunName", value.addFunName);
			xml.addPropertie("singlenChild", value.singlenChild.toString());
			xml.addPropertie("hasFont", value.hasFont.toString());
			var childRen:XMLTool = new XMLTool("childRen");
			xml.addContent(childRen.toString());
			var i:int = 0;
			var len:uint = value.attribute.length;

			var Properties:XMLTool = new XMLTool("Properties");

			for (i = 0; i < len; i++)
			{
				var att:AttributeStructural = value.attribute[i] as AttributeStructural;
				var child:XMLTool = new XMLTool("Propertie");
				child.addPropertie("name", att.name);
				child.addPropertie("value", att.value);
				child.addPropertie("isMethod", att.isMethod.toString());
				child.addPropertie("type", att.type);
				child.addPropertie("describe", att.describe);
				Properties.addContent(child.toString());
			}
			xml.addContent(Properties.toString());

			i = 0;
			len = value.styleList.length;
			var stylePropertie:XMLTool = new XMLTool("Styles");
			for (i = 0; i < len; i++)
			{
				var style:StyleData = value.styleList[i] as StyleData;
				var styleXML:XMLTool = new XMLTool("style");
				styleXML.addPropertie("skinMethod", style.skinMethod);
				styleXML.addPropertie("describe", style.describe);
				styleXML.addPropertie("setObjectName", style.setObjectName);
				styleXML.addPropertie("type", style.type);
				styleXML.addPropertie("valueName", style.skinName);
				styleXML.addPropertie("skinType", "none");
				styleXML.addPropertie("skinName", "none");
				styleXML.addPropertie("grid", "0-0-0-0");
				stylePropertie.addContent(styleXML.toString());
			}
			xml.addContent(stylePropertie.toString());
			return xml.toXml();
		}

		public function removeName(value:String):void
		{
			_nameDic[value] = null;
			delete _nameDic[value];
		}


		/*private function checkInstanceName(value:String):Boolean
		   {
		   var result:Boolean = false;
		   if(_nameDic[value] == null && _nameDic[value] == value)
		   {
		   result = false;
		   }
		   else
		   {
		   result = true;
		   }
		   return result
		 }*/

		private function saveRandomInstanceName(value:String):String
		{
			var name:String = null;
			nameDo: while (true)
			{
				name = (value + "_instanceName" + Math.random() * 0xFFFFFF as String).replace(/\./gi, "_");
				if (_nameDic[name] == null)
				{
					_nameDic[name] = name;
					break nameDo;
				}
				else
				{
					name = null;
				}
			}
			return name;
		}

	}
}