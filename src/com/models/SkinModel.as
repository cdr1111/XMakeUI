package com.models
{
	import com.enum.SkinType;
	import com.structurals.SkinStructural;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	/**
	 * 存放皮肤的数据
	 */ 
	public class SkinModel extends EventDispatcher
	{
		static private var _instance:SkinModel = null;
		
		private var _swfDomian:ApplicationDomain = null;
		private var _skinList:Array = null;
		public function SkinModel(target:IEventDispatcher=null)
		{
			super(target);
			_skinList = new Array();
		}
		
		public static function get Instance():SkinModel
		{
			if(null == _instance)
			{
				_instance = new SkinModel();				
			}	
			return _instance;
		}
		
		public function set skinSwfDomain(value:ApplicationDomain):void
		{
			_swfDomian = value;
		}
		
		public function get skinList():Array
		{
			return this._skinList;
		}
		
		public function set swfXMLData(value:String):void
		{
			var xml:XML = new XML(value.replace(/ xmlns=.*swccatalog\/9\"/, ""));
			var i:int = 0;
			var len:int = xml.libraries.library.script.length();
			for(i = 0; i < len; i++)
			{
				_skinList.push(createSkinStructural(xml.libraries.library.script[i], SkinType.SWF_SKIN) );
			}
		}
		
		public function getClsByClassName(value:String):Class
		{
			return this._swfDomian.getDefinition(value ) as Class;
		}
		
		public function set urlXMLData(value:String):void
		{
			/*var xml:XML = new XML(value);
			var i:int = 0;
			var len:int = xml.resource.image.length();
			for(i = 1; i < len; i++)
			{
				_skinList.push(createSkinStructural(xml.resource.image[i], SkinType.URL_SKIN) );
			}*/
		}
		
		public function getURLComparativelyPath(url:String):String
		{
			var path:String = "";
			var folders:Array = url.split("/");
			var i:int = 0;
			var len:int = folders.length;
			for(i = len; i > (len - 2); i--)
			{
				path += "%" + folders[i - 1];
			}
			path = path.substr(1);
			return path;
		}
		
		private function createSkinStructural(xml:XML, type:String):SkinStructural
		{
			var skin:SkinStructural = new SkinStructural();
			skin.skinName = xml.@name;
			skin.type = type;
			return skin;
		}
	}
}