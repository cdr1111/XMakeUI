package com.main
{
	import com.enum.TypeEnum;
	import com.structurals.StyleData;
	import com.tools.TypeConversion;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	public class OtherStyleSettingPanel extends UIComponent
	{
		
		private static var _instance:OtherStyleSettingPanel = null;
		
		private var _setOtherStyleValuePanel:SetOtherStyleValuePanel = new SetOtherStyleValuePanel();
		
		
		public function OtherStyleSettingPanel()
		{
			super();
			addChild(_setOtherStyleValuePanel);
			_setOtherStyleValuePanel.x = 300;
			_setOtherStyleValuePanel.y = 200;
			_setOtherStyleValuePanel.visible = false;
			_setOtherStyleValuePanel.okBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
		
		private var _currentDisplay:DisplayObject = null;
		
		private var _xml:XML = null;
		
		private var _currentStyleData:StyleData = null;
		public function showPanel(styleData:StyleData, xml:XML, currentDisplay:DisplayObject):void
		{
			_currentDisplay = currentDisplay;
			_xml = xml;
			_currentStyleData = styleData;
			_setOtherStyleValuePanel.visible = true;
			_setOtherStyleValuePanel.styleName.text = styleData.describe;
			var type:String = _currentStyleData.type;
			this._setOtherStyleValuePanel.typeLabel.text = type;
			
			/*if(type != TypeEnum.string)
			{
				
				_setOtherStyleValuePanel.valueTxt.restrict = "[0-9]";
			}
			else
			{
				_setOtherStyleValuePanel.valueTxt.restrict = "";
			}*/
		}
		
	
		
		public static function get Instance():OtherStyleSettingPanel
		{
			if(null == _instance)
			{
				_instance = new OtherStyleSettingPanel();				
			}	
			return _instance;
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void
		{
			
			var type:String = _currentStyleData.type;
				//this._setOtherStyleValuePanel.typeCB.dataProvider[this._setOtherStyleValuePanel.typeCB.selectedIndex].label;
			
			var value:String = 	_setOtherStyleValuePanel.valueTxt.text;
				
			_currentDisplay[_currentStyleData.skinMethod](_currentStyleData.skinName, TypeConversion.convert(value, type) );
			
			_setOtherStyleValuePanel.visible = false;
			
			var styleListL:XMLList = _xml.Styles.style.(@valueName == _currentStyleData.skinName);
			
			styleListL.@skinName = value;
			styleListL.@skinType = 	type;
		}
		
		
	}
}