package com.models
{
	import com.enum.TypeEnum;
	import com.tools.XMLTool;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	/** 生成AS代码和XML配置的 @author gehui*/ 
	public class BuildCoder extends EventDispatcher
	{
		
		static private var _instance:BuildCoder = null;
		private var _className:String = null;
		private var _packageName:String = "";
		private var _classDesc:String = "";
		private var _importList:Array = null;
		private var _createUIList:Array = null;
		private var _addUIToStageList:Array = null;
		private var _getUIList:Array = null;
		private var _attributeList:Array = null;
		private var _styleList:Array = null;
		
		private var _fontCodeList:Array = null;
		
		private var _configAttList:Dictionary = null;
		private var _configStyleList:Dictionary = null;		
		private var _fontList:Dictionary = null;		
		public function BuildCoder(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function get ClassName():String
		{
			return this._className;
		}
		
		public function set ClassName(value:String):void
		{
			this._className = value;
			CreateUIModel.Instance.code.@ClassName = value;
		}
		
		public function get PackageName():String
		{
			return this._packageName;
		}
		
		public function set PackageName(value:String):void
		{
			this._packageName = value;
			CreateUIModel.Instance.code.@PackageName = value;
		}
		
		public function get ClassDesc():String
		{
			return this._classDesc;
		}
		
		public function set ClassDesc(value:String):void
		{
			this._classDesc = value;
			CreateUIModel.Instance.code.@ClassDesc = value;
		}
		
		public static function get Instance():BuildCoder
		{
			if(null == _instance)
			{
				_instance = new BuildCoder();				
			}	
			return _instance;
		}
		
		public function parseToAScode(xml:XML):void
		{
			init();
			var i:int = 0;
			var len:int = xml.childRen.ui.length();
			for(i = 0; i < len; i++)
			{
				parseUi(xml.childRen.ui[i]);
			}	
		}
		
		private function init():void
		{
			_importList = [];
			_createUIList = [];
			_addUIToStageList = [];
			_getUIList = [];
			_attributeList = [];
			_styleList = [];
			_fontCodeList = [];
			_fontList = new Dictionary();
			_configAttList = new Dictionary();
			_configStyleList = new Dictionary();
			var arrBase:Array = UIParser.Instance._baseClass.split(";");
			for each(var one:String in arrBase)
				pushImport("import " + one + ";");
				
			if (UIParser.Instance._dataInterface && (UIParser.Instance._dataInterface.length > 0))
			{
				pushImport("import " + UIParser.Instance._dataInterface + ";");
			}			
		}
		
		override public function toString():String
		{
			var content:String = "package ";
			content += this._packageName + "\r\n{\r\n";
			content += foreachGetContent(_importList, "\t");
			content += "\r\n\t/** " + this._classDesc + "*/\r\n";
			content += "\tpublic class " + ClassName + " extends UIBuildBase\r\n";
//			content += "\tpublic class " + ClassName + " extends UIBuildBase implements IDataUI\r\n";
			content += "\t{\r\n";
			content += foreachGetContent(_createUIList, "\t\t");
//			content += "\r\n\t\tprivate var _vo:DarcyVO;\r\n";
			content +=  "\r\n\t\tpublic function " + ClassName + "()\r\n" +
						"\t\t{\r\n" +
						"\t\t\tthis.localizationName = \"" + ClassName + "\";\r\n" +
						"\t\t\tinitView();\r\n" +
						"\t\t}\r\n\r\n";
			//get
			content += foreachGetContent(_getUIList, "\t\t");
			
//			content += "\t\tpublic function get vo():DarcyVO{return this._vo;}\r\n\r\n ";
//			
//			content += "\t\tpublic function set vo(value:DarcyVO):void{this._vo = value;}\r\n\r\n ";
			
			content +=  "\t\tprivate function initView():void\r\n" +
						"\t\t{\r\n" +
						"\t\t\taddChildToStage();\r\n" +
						"\t\t}\r\n";
			
			content +=  "\r\n\t\tprivate function addChildToStage():void\r\n" +
						"\t\t{\r\n";
			content += foreachGetContent(_addUIToStageList, "\t\t\t");
			content += "\t\t}\r\n";
			
			content +=  "\r\n\t\toverride protected function setAttribute():void\r\n" +
						"\t\t{\r\n";
			content += foreachGetContent(_attributeList, "\t\t\t");
			content += "\t\t}\r\n";
			
			content +=  "\r\n\t\toverride protected function setUISkins():void\r\n" +
						"\t\t{\r\n";
			content += foreachGetContent(this._styleList, "\t\t\t");
			content += "\t\t}\r\n";
			
			content +=  "\r\n\t\toverride protected function setUIFont():void\r\n" +
						"\t\t{\r\n";
			content += foreachGetContent(this._fontCodeList, "\t\t\t");
			content += "\t\t}\r\n";
			
			content += "\t}\r\n}";
			return content;
		}
		
		public function buildConfigXML():String
		{
			var xml:XMLTool = new XMLTool("Class");
			xml.addPropertie("name", this.ClassName);
			xml.addPropertie("font", CreateUIModel.Instance.code.@defaultFont);
			
			xml.addContent(getConfigAtt());
			xml.addContent(getConfigStyle());
			xml.addContent(addFont());
			return xml.toString();
		}
		
		private function addFont():String
		{
			var xml:XMLTool = new XMLTool("fonts");
			xml.addContent("\r\n");
			var key:String = null;
			for (key in this._fontList)
			{
				var xmlList:XMLTool = new XMLTool("font");
				xmlList.addPropertie("name", key);
				xmlList.addPropertie("value", this._fontList[key]);
				xml.addContent(xmlList.toString() + "\r\n");
			}
			return xml.toString();
		}
		
		
		private function getConfigStyle():String
		{
			var xml:String = "";
			var key:String = null;
			for (key in this._configStyleList)
			{
				var atts:Array = _configStyleList[key];
				var i:int = 0;
				var len:int = atts.length;
				if(len != 0)
				{
					var xmlList:XMLTool = new XMLTool("styles");
					xmlList.addContent("\r\n");
					xmlList.addPropertie("name", key);
					for(i = 0; i < len; i++)
					{
						//	styles.push(style + "@" + value + "@" 
						//+ type + "@" + xml.Styles.style[i].@grid);
						var content:String = atts[i] as String;
						var att:Array = content.split("@");
						xmlList.addPropertie(att[0], content.replace(att[0] + "@", ""));			
					}
					xml += xmlList.toString() + "\r\n";
				}
			}
			return xml;
		}
		
		
		
		private function getConfigAtt():String
		{
			var xml:String = "";
			var key:String = null;
			for (key in this._configAttList)
			{
				var atts:Array = _configAttList[key];
				var i:int = 0;
				var len:int = atts.length;
				if(len != 0)
				{
					var xmlList:XMLTool = new XMLTool("atts");
					xmlList.addContent("\r\n");
					xmlList.addPropertie("name", key);
					for(i = 0; i < len; i++)
					{
						var content:String = atts[i] as String;
						var att:Array = content.split("=")
						xmlList.addPropertie(att[0], att[1]);
					
					}
					xml += xmlList.toString() + "\r\n";
				}
			}
			return xml;
		}
		
		private function foreachGetContent(value:Array, space:String = ""):String
		{
			var content:String = "";
			var i:int = 0;
			var len:int = value.length;
			for(i = 0; i < len; i++)
			{
				content += space + value[i] + "\r\n";
			}
			return content;
		}
		
		private function parseUi(xml:XML):void
		{
			pushImport("import " + xml.@fullName + ";");
			createUI(xml, xml.parent().parent());
			var i:int = 0;
			var len:int = xml.childRen.ui.length();
			for(i = 0; i < len; i++)
			{
				parseUi(xml.childRen.ui[i]);
			}
		}
		 
		private function createUI(xml:XML, parent:XML):void
		{
			var name:String = xml.@fullName.toString();
			if(xml.@hasFont.toString() == "true")
			{
				var contentTxt:String = "";
				if(xml.@font.toString() != null && xml.@font.toString() != "")
				{
					_fontList[xml.@instanceName.toString()] =  xml.@font.toString();			
				}
				else
				{
					_fontList[xml.@instanceName.toString()] = "defaultFont";
				}
				contentTxt = "this.setFontStyle(" + xml.@instanceName + ",\"" + xml.@instanceName + "\")";
				_fontCodeList.push(contentTxt);
			}
			name = name.substr(name.lastIndexOf(".") + 1);
			//new 操作
			var content:String = "private var " + xml.@instanceName + ":" + name + " = new " + name + "();";
			_createUIList.push(content);		
			//添加到显示列表操作
			
			var addFunName:String = parent.@addFunName;
			if(addFunName.indexOf("set") != -1 && xml.@parentName != "this")
			{
				addFunName = addFunName.split("|")[1] + " = ";
			}
			else if(addFunName.indexOf("fun") != -1)
			{
				addFunName = addFunName.split("|")[1];
			}
			else if(xml.@parentName == "this")
			{
				addFunName = "addChild";
			}
			var addChildFunction:String = xml.@parentName + "." + addFunName + "(" + xml.@instanceName + ");";
			_addUIToStageList.push(addChildFunction);
			//get 方法操作
			var getFunction:String = "public function get Get" + xml.@instanceName + "():" + name + "\r\n" +
				"\t\t{\r\n " +
				"\t\t\treturn " + xml.@instanceName + ";\r\n" +
				"\t\t}\r\n";
			_getUIList.push(getFunction);
			//设置属性
			setAttribute(xml, xml.@instanceName);
			setStyle(xml, xml.@instanceName);
		}
		//_styleList	
		private function setStyle(xml:XML, targetName:String):void
		{
			var len:int = xml.Styles.style.length();
			var i:int = 0;
			var styles:Array = [];
			for(i = 0; i < len; i++)
			{
				var value:String = xml.Styles.style[i].@skinName;
				var type:String = xml.Styles.style[i].@skinType;
				var uiName:String = targetName;
				var style:String = xml.Styles.style[i].@valueName;
				var skinType:String = xml.Styles.style[i].@type;
				if(value != "none")  
				{ 
					//var content:String = "this.setResourceToUI(" + uiName + 
					//", \"" + value + "\", \"" + style + "\", \"" + type + "\", \"" + xml.Styles.style[i].@grid + "\");";
					styles.push(style + "@" + value + "@" + type + "@" + xml.Styles.style[i].@grid + "@"  +  skinType);
					//var content:String = 
					//_styleList.push(content);
				}
			}
			_configStyleList[targetName] = styles;
			var styleContent:String = "this.setResourceToUI(" + targetName + "," + "\"" + targetName +"\");";
			_styleList.push(styleContent);
		}	
			
			
		private function setAttribute(xml:XML, targetName:String):void
		{
			var len:int = xml.Properties.Propertie.length();
			var i:int = 0;
			var atts:Array = [];
			for(i = 0; i < len; i++)
			{
				var type:String = xml.Properties.Propertie[i].@type;
				var value:String = xml.Properties.Propertie[i].@value;
				var TypeFlag:String = null;
				
				switch(type)
				{
					case TypeEnum.string:
					TypeFlag = "@s";
					break;
					case TypeEnum.bool:
					TypeFlag = "@b";
					break;
					case TypeEnum.int:
					TypeFlag = "@i";
					break;
					case TypeEnum.number:
					TypeFlag = "@n";
					break;
					case TypeEnum.uint:
					TypeFlag = "@u";
					break;
				}
				
				var attName:String = xml.Properties.Propertie[i].@name;
				var isMethod:Boolean = xml.Properties.Propertie[i].@isMethod == "true";
				//var content:String = targetName + "." + xml.Properties.Propertie[i].@name;
				//var evaluate:String = isMethod ? attName + "(" + value + ")" : " = " + value;
				//content += evaluate + ";";	
				atts.push(attName + "=" +  value + TypeFlag);
			}
			_configAttList[targetName] = atts;
			var content:String = "this.setProperties(" + targetName + ", " +  "\"" + targetName + "\");";
			_attributeList.push(content)
		}
		
		private function pushImport(value:String):void
		{
			if(_importList.indexOf(value) == -1)
			{
				_importList.push(value);
			}
		}
		
	}
}








/**

private function setStyle(xml:XML, targetName:String):void
		{
			var len:int = xml.Styles.style.length();
			var i:int = 0;
			for(i = 0; i < len; i++)
			{
				var value:String = xml.Styles.style[i].@skinName;
				var type:String = xml.Styles.style[i].@skinType;
				var uiName:String = targetName;
				var style:String = xml.Styles.style[i].@valueName;
				if(value != "none")
				{
					var content:String = "this.setResourceToUI(" + uiName + 
					", \"" + value + "\", \"" + style + "\", \"" + type + "\", \"" + xml.Styles.style[i].@grid + "\");";
					_styleList.push(content);
				}
			}
		
		}	
			
			
		private function setAttribute(xml:XML, targetName:String):void
		{
			var len:int = xml.Properties.Propertie.length();
			var i:int = 0;
			for(i = 0; i < len; i++)
			{
				var type:String = xml.Properties.Propertie[i].@type;
				var value:String = xml.Properties.Propertie[i].@value;
				if(type == TypeEnum.string)
				{
					value = "\"" + value + "\"";
				}
				var attName:String = xml.Properties.Propertie[i].@name;
				var isMethod:Boolean = xml.Properties.Propertie[i].@isMethod == "true";
				var content:String = targetName + "." + xml.Properties.Propertie[i].@name;
				
				var evaluate:String = isMethod ? attName + "(" + value + ")" : " = " + value;
				content += evaluate + ";";
				_attributeList.push(content);
			}
		}


*/