package com.events
{
	import com.models.UIInstanceInfo;
	import com.structurals.UIStructural;
	
	import flash.events.Event;
	
	public class MainContainerEvent extends Event
	{
		public static const COPY_UI:String = "copy_ui";
		
		public static const UPDATE_INSTANCE_LIST:String = "update_instance_list";
		
		public var copyUIData:UIInstanceInfo = null;
		
		public function MainContainerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		
		
	}
}