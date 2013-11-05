package com.undo
{
	import com.models.UIInstanceInfo;

	/**
	 * 属性改变操作
	 * @author tangzhixu
	 * @date 2011-10-17
	 */	
	public class AttributeChangeOperation extends OperationBase
	{
		private var uiInfo:UIInstanceInfo;
		private var attName:String;
		private var oldValue:*;
		private var newValue:*;
		public function AttributeChangeOperation(uiInfo:UIInstanceInfo, attName:String, oldValue:*, newValue:*)
		{
			super();
			this.uiInfo = uiInfo;
			this.attName = attName;
			this.oldValue = oldValue;
			this.newValue = newValue;
		}
		
		override public function performUndo():void
		{
			uiInfo.displayObj[attName] = oldValue;
			layout.propertyPanel.updateAttributeFromUI();
		}
		
		override public function performRedo():void
		{
			uiInfo.displayObj[attName] = newValue;
			layout.propertyPanel.updateAttributeFromUI();
		}
	}
}