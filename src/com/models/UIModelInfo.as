package com.models
{
	import com.structurals.UIStructural;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	
	/**
	 * 解析后的ui信息
	 * 存放了UI组件的配置
	 */ 
	public class UIModelInfo extends EventDispatcher
	{
		static private var _instance:UIModelInfo = null;
		
		/**
		 * UI域
		 */
		public var appDomain:ApplicationDomain = null;		
		/**
		 * ui存放的URL
		 */ 
		public var swfURL:String = null;
		/**
		 * UI列表
		 * 元素：UIStructural
		 */ 
		private var _uiList:Array = null; 
		  
		public function UIModelInfo(target:IEventDispatcher=null)
		{
			super(target);
			if(_instance != null)
			{
				throw new Error("无法实例化");
			}
			_uiList = [];
		}
		
		public static function get Instance():UIModelInfo
		{
			if(null == _instance)
			{
				_instance = new UIModelInfo();
				
			}	
			return _instance
		}
		
		public function insertUIStructural(value:UIStructural):void
		{
			_uiList.push(value);
		}
		
		public function get UIList():Array
		{
			return this._uiList;
		}
		
	}
}