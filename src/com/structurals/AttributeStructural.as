package com.structurals
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	/**
	 * 属性结构体
	 */ 
	public class AttributeStructural extends EventDispatcher
	{
		/**
		 *  属性名
		 */ 
		[Bindable]
		public var name:String = null;
		/**
		 *	属性值
		 */
		[Bindable]
		public var value:* = null;
		/**
		 * 描述
		 */
		[Bindable]
		public var describe:String = null;
		/**
		 * 属性类型
		 */  
		public var type:String = null;
		/**
		 * 是否是方法
		 */
		public var isMethod:Boolean = false;
		/**
		 * 
		 */
		public var xml:XML = null;      
		public function AttributeStructural(target:IEventDispatcher=null)
		{
			super(target);
		}
		
	}
}