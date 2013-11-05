package com.ui
{
	import fl.core.UIComponent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	public class UIBaseSprite extends UIComponent
	{
		private var _bg:Sprite = new Sprite();
		private var _content:DisplayObject = null;
		public function UIBaseSprite()
		{
			addChild(_bg);
			_bg.graphics.beginFill(0xFFF00F, 0.1);
			_bg.graphics.drawRect(0, 0, 100, 100);
		}
		
		public function get content():DisplayObject
		{
			return _content;
		}
		
		override public function set width(value:Number):void
		{
			_bg.width = value;
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			_bg.height = value;
			super.height = value;
		}
		
		override public function get width():Number
		{
			return _bg.width;
		}
		
		override public function get height():Number
		{
			return _bg.height ;
		}
		
		
		override public function setStyle(style:String, value:Object):void
		{
			if(_content)
			{
				this.removeChild(_content);
			}
			_content = value as DisplayObject;
			this.addChildAt(value as DisplayObject, 0);
			
		}
		
	}
	
}