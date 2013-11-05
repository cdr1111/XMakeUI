package com.ui
{	
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	public class UISprite extends Sprite
	{
		private var _bg:Sprite = new Sprite();
		private var _content:DisplayObject = null;
		private var _contentWidth:Number = -1;
		private var _contentHeight:Number = -1;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		public function UISprite()
		{
			addChild(_bg);		
			_bg.graphics.beginFill(0, 0.2);
			_bg.graphics.drawRect(0, 0, 200, 200);
			
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
		
		public function set contentWidth(value:Number):void
		{
			_contentWidth = Number(value); 
			uiResize();
		}
		
		public function set contentHeight(value:Number):void
		{ 
			_contentHeight = Number(value); 
			uiResize()
		}
		
		
		override public function set scaleX(value:Number):void
		{
			_scaleX = value;
			if(_content == null) return;
			_content.scaleX = value;
			
		}
		override public function set scaleY(value:Number):void
		{
			_scaleY = value;
			if(_content == null) return;
			_content.scaleY = value;
		}
		
		private function uiResize():void
		{
			if(_content == null) return;
			if(_contentWidth != -1)
			{
				_content.width = _contentWidth;
			}
			if(_contentHeight != -1)
			{
				_content.height = _contentHeight;
			}
		}
		
		
		public function setStyle(style:String, value:Object):void
		{
			if(_content)
			{
				this.removeChild(_content);
			}	
			_content = value as DisplayObject;
			_content.x = this.width / 2 - _content.width / 2;
			_content.y = this.height / 2 - _content.height / 2;
			this.addChildAt(value as DisplayObject, 1);
		}
		
	}
	
}