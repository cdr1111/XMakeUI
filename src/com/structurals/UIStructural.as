package com.structurals
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * 每一个UI的结构
	 */ 
	public class UIStructural extends EventDispatcher
	{
		public var singlenChild:Boolean = false;
		public var addFunName:String = null;
		public var autoLayOut:Boolean = false;
		public var uiName:String = null;
		public var isContainer:Boolean = false;
		public var hasFont:Boolean = false;
		public var xml:XML = null;
		/**
		 *创建UI时，名字的前缀 
		 */		
		public var instancePrefix:String = "";
		private var _attribute:Array = null;
		private var _styleList:Array = null;
		public function UIStructural(target:IEventDispatcher=null)
		{
			super(target);
			_attribute = [];
			_styleList = [];
		}
		
		public function addAattribute(value:AttributeStructural):void
		{
			_attribute.push(value);	
		}
		
		public function get attribute():Array
		{
			return _attribute;
		}
		
		public function addStyle(value:StyleData):void
		{
			_styleList.push(value);	
		}
		
		public function get styleList():Array
		{
			return _styleList;
		}
	}
}