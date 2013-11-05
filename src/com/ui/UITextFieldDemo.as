package com.ui
{
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import mx.core.UIComponent;

	public class UITextFieldDemo extends mx.core.UIComponent
	{
		private var _txt:TextField = new TextField();
		private var _filter:GlowFilter = new GlowFilter(0xff0000, 1, 3, 3);
		private var _hasfilter:Boolean = false;

		public function UITextFieldDemo()
		{
			super();
			_txt.text = "自定义标签";
			_txt.height = 160;
			_txt.width = 220;
			addChild(_txt);
			wordWrap = true;
			multiline = true;
		}

		public function set wordWrap(value:Boolean):void
		{
			_txt.wordWrap = value;
		}

		public function set multiline(value:Boolean):void
		{
			_txt.multiline = value;
		}

		public function set text(value:String):void
		{
			_txt.text = value;
		}

		override public function set width(value:Number):void
		{
			_txt.width = value;
		}

		override public function set height(value:Number):void
		{
			_txt.height = value;

		}

		public function set hasfilter(value:Boolean):void
		{
			_hasfilter = value;
			if (value == false)
			{
				_txt.filters = [];
			}
			else
			{
				_txt.filters = [_filter];
			}
		}

		public function set selectedTab(value:Boolean):void
		{
			_txt.selectable = value;
		}

		public function set newfilter(value:GlowFilter):void
		{
			_filter = value;
			if (_hasfilter == false)
				return;
			_txt.filters = [_filter];
		}

		public function set filterColor(value:uint):void
		{
			_filter.color = value;
			if (_hasfilter == false)
				return;
			_txt.filters = [_filter];
		}

		override public function setStyle(style:String, value:*):void
		{
			if (style == "textFormat")
			{
				_txt.setTextFormat(value as TextFormat);
				_txt.defaultTextFormat = value as TextFormat;
			}
		}
	}
}