package com.models
{
	import com.structurals.UIStructural;
	import com.tools.TypeConversion;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;

	/**
	 * 已经创建好的 ui 数据
	 */ 
	public class UIInstanceInfo extends EventDispatcher
	{
		public var locked:Boolean = false;
		
		public var layerLocked:Boolean = false;
		
		public var uiData:UIStructural = null;
		
		public var displayObj:DisplayObject = null;
		
		private var _infoXML:XML = null;
		
		//private var _viewBuildParser:ViewBuildParser = new ViewBuildParser();
		
		public function updateView():void
		{
			//_viewBuildParser.updateView(this.infoXML, displayObj);
		}
		
		public function getAttributeValue(name:String):Object
		{
			var xml:XMLList = infoXML.Properties.Propertie.(@name == name);
			return TypeConversion.convert(xml.@type, xml.@value);;
		}
		
		public function get parentName():String
		{
			return this.infoXML.@parentName.toString();
		}
		
		public function get isContainer():Boolean
		{
			return this.infoXML.@isContainer.toString() == "true";
		}
		
		public function get fullName():String
		{
			return this.infoXML.@fullName.toString();
		}
		
		public function get instanceName():String
		{
			return this.infoXML.@instanceName.toString();
		}
		
		public function get autoLayOut():Boolean
		{
			return this.infoXML.@autoLayOut == "true";
		}

		public function get infoXML():XML
		{
			return _infoXML;
		}

		public function set infoXML(value:XML):void
		{
			_infoXML = value;
		}

	}
}