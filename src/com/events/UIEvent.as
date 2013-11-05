package com.events
{
	import com.models.UIInstanceInfo;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class UIEvent extends Event
	{
		public static var UPDATE_CODE:String = "update_code";
		public static var ATTRIBUTE_CHANGE:String = "attributeChange";
		public static var SELECTED_UI:String = "selected_ui";
		public static var MAIN_MOVED:String = "main_moved";

		public var oldValue:* = null;
		public var changeValue:* = null;
		public var changeAttName:String = null;
		public var selectedUi:DisplayObject = null;
		public var data:UIInstanceInfo = null;

		public function UIEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}