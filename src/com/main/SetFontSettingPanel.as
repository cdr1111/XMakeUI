package com.main
{
	import com.structurals.StyleData;
	import com.tools.TypeConversion;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;

	public class SetFontSettingPanel extends UIComponent
	{
		private static var _instance:SetFontSettingPanel = null;
		private var _textStylePanel:TextStylePanel = new TextStylePanel();

		public function SetFontSettingPanel()
		{
			super();
			
			_textStylePanel.x = 300;
			_textStylePanel.y = 200;
			_textStylePanel.visible = false;
			
		}

		private var _currentDisplay:DisplayObject = null;
		private var _xml:XML = null;
		private var _currentStyleData:StyleData = null;

		public function showPanel(styleData:StyleData, xml:XML, currentDisplay:DisplayObject):void
		{
			this.visible = true;
			_currentDisplay = currentDisplay;
			_xml = xml;
			_currentStyleData = styleData;
			_textStylePanel.visible = true;
			
			var tf:TextFormat = currentDisplay["getStyle"](styleData.skinName);
			_textStylePanel.setFormat(tf);
			this.addChild(_textStylePanel);
		}

		public static function get Instance():SetFontSettingPanel
		{
			if (null == _instance)
			{
				_instance = new SetFontSettingPanel();
			}
			return _instance;
		}

		private function onMouseClickHandler(evt:MouseEvent):void
		{
			var type:String = _currentStyleData.type;
			var value:String = getTextFormatToString(_textStylePanel.getFormat());
			_currentDisplay[_currentStyleData.skinMethod](_currentStyleData.skinName, TypeConversion.convert(value, type));
			_textStylePanel.visible = false;
			var styleListL:XMLList = _xml.Styles.style.(@valueName == _currentStyleData.skinName);
			styleListL.@skinName = value;
			styleListL.@skinType = type;
		}

		private function getTextFormatToString(value:TextFormat):String
		{
			var font:String = null;
			if (value.italic != null && value.leading != null && value.underline != null && value.letterSpacing != null)
			{
				font = value.align + "|" + value.bold + "|" + value.color + "|" + value.font + "|" + value.size + "|" + value.italic + "|" + value.leading + "|" + value.letterSpacing + "|" + value.underline;
			}
			else
			{
				font = value.align + "|" + value.bold + "|" + value.color + "|" + value.font + "|" + value.size;
			}
			return font;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
		
			if(_textStylePanel.confirm) _textStylePanel.confirm.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
	}
}