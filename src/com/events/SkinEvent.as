package com.events
{
	import com.models.UIInstanceInfo;
	import com.structurals.StyleData;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * 
	 * @author tangzhixu
	 * @date 2011-10-18
	 */	
	public class SkinEvent extends Event
	{
		public static const SELECT_SWF_SKIN:String = "selectSwfSkin";
		
		public var styleData:StyleData;
		public var xml:XML;
		public var display:DisplayObject;
		public var skinType:String;
		public var instance:UIInstanceInfo;
		
		public function SkinEvent(type:String)
		{
			super(type);
		}
	}
}