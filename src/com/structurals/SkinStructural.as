package com.structurals
{
	import com.enum.SkinType;
	
	import flash.display.DisplayObject;
	import flash.system.ApplicationDomain;

	/**
	 * 皮肤结构
	 */ 
	public class SkinStructural
	{
		public var type:String = SkinType.SWF_SKIN;
		public var skinName:String = null;
		public var skinType:String = null;
		public var skinDomain:ApplicationDomain;
		
		public function create():DisplayObject
		{
			var clazz:Class = skinDomain.getDefinition(skinName) as Class;
			return new clazz();
		}
	}
}