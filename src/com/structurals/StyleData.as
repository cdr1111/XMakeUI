package com.structurals
{
	/**
	 * 样式数据
	 */ 
	public class StyleData
	{
		/**
		 * 数据类型
		 */ 
		public var type:String = null;
		/**
		 * 设置的皮肤的类型
		 */ 
		public var skinName:String = null;
		/**
		 * gehui 将其修改为私有类型 
		 */		
		private var _skinMethod:String = null;
		/**
		 * 设置的对象
		 */ 
		public var setObjectName:String = null;
		/**
		 * 描述
		 */ 
		public var describe:String = null;

		/**
		 * 设置属性的方法名
		 */
		public function get skinMethod():String
		{
			return _skinMethod;
		}

		/**
		 * @private
		 */
		public function set skinMethod(value:String):void
		{
			_skinMethod = value;
		}

	}
}
