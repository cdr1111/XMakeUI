package com.models
{
	import com.enum.TypeEnum;
	import com.structurals.AttributeStructural;
	import com.structurals.StyleData;
	import com.structurals.UIStructural;
	import com.tools.TypeConversion;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * 解析FLASH配置的
	 */ 
	public class UIParser extends EventDispatcher
	{
		static private var _instance:UIParser = null;
		public var resource_URL:String = null;
		/**
		 *界面拼接工具加载项目时用的 
		 */		
		public var _toolXMLURL:String = null;
		/**
		 *游戏项目中用到的 
		 */		
		public var _configXMLURL:String = null;
		
		public var _sourceXMLURL:String = null;
		
		public var packagePrefix:String = null;
		
		public var classDesc:String = null;
		
		public var _baseClass:String = null;
		
		public var _dataInterface:String = null;
		
		public function UIParser(target:IEventDispatcher=null)
		{
			super(target);
			if(_instance != null)
			{
				throw new Error("无法实例化");
			}
		}
		/**
		 * z只能通过此方法才可得到实例
		 */ 
		public static function get Instance():UIParser
		{
			if(null == _instance)
			{
				_instance = new UIParser();
			}	
			return _instance
		} 
		
		public function parse(xml:XML):void
		{
			resource_URL = xml.resourceURL.toString();
			this._toolXMLURL = xml.toolXML.toString();
			this._sourceXMLURL = xml.sourceXML.toString();
			this._configXMLURL = xml.configXML.toString();
			packagePrefix = xml.packagePrefix.toString();
			classDesc = xml.classDesc.toString();
			this._baseClass = xml.baseClass.toString();
			this._dataInterface = xml.dataInterface.toString();
			var len:uint = xml.ui.length();
			var i:int = 0;
			for(i = 0; i < len; i++)
			{
				UIModelInfo.Instance.insertUIStructural(parseUI(xml.ui[i] as XML));	
			}
		}
		
		public function parseUIByCodeXML(xml:XML):UIStructural
		{
			var s:UIStructural = new UIStructural();
			s.xml = xml;
			this.makeUI(s,xml);
			return s;
		}
		
			
		public function parseUI(xml:XML):UIStructural
		{
			var s:UIStructural = new UIStructural();
			this.makeUI(s,xml);
			
			for each(var styleXML:XML in xml..style)
			{
				var style:StyleData = this.parseStyleAttribute(styleXML);
				s.addStyle(style);
			}
			
			return s;
		}
		
		private function makeUI(s:UIStructural,xml:XML):void
		{
			s.uiName = xml.@fullName.toString();
			s.instancePrefix = xml.@instancePrefix.toString();
			s.isContainer = xml.@isContainer.toString() == "true";
			s.autoLayOut = xml.@autoLayOut.toString() == "true";
			s.singlenChild = xml.@singlenChild.toString() == "true";
			s.addFunName = xml.@addFunName.toString();
			s.hasFont = xml.@hasFont.toString() == "true";	
			
			var list:XMLList = xml.elements("Properties")[0].children();
			for each(var attrXML:XML in list)
			{
				var attr:AttributeStructural = parseAttribute(attrXML);
				s.addAattribute(attr);
			}
		}
		
		private function parseStyleAttribute(xml:XML):StyleData
		{
			var style:StyleData = new StyleData();
			style.skinName = xml.@styleName;
			style.type = xml.@type;
			style.skinMethod = xml.@skinMethod;
			style.describe = xml.@describe;
			style.setObjectName = xml.@setObjectName;
			return style;
		}	
			
		private function parseAttribute(xml:XML):AttributeStructural
		{
			var a:AttributeStructural = new AttributeStructural();	
			a.name = xml.@name.toString();
			a.describe = xml.@describe.toString();
			a.type = xml.@type.toString();
			if(xml.@value.toString() == "")
			{
				if(a.type == TypeEnum.int || a.type == TypeEnum.number || a.type == TypeEnum.uint)
				{
					a.value = "";
				}
				else
				{
					a.value = TypeConversion.convert(xml.@value.toString(), xml.@type.toString());
				}
			}
			else
			{
				a.value = TypeConversion.convert(xml.@value.toString(), xml.@type.toString());
			}
			
			a.isMethod = false;	
			a.xml = xml;		
			return a;
		}	
		
		/**
		 * 解析生成的UI——XML
		 */ 
		
		
		
	}
}
/*
			var obj:* = null;
			var i:int = 0;
			var len:int = xml.attributes().length();	
			for(i = 0; i < len; i++)
			{
				trace(xml.@*[i].name())
			}
*/