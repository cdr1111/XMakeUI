package com.undo
{
	import com.models.UIInstanceInfo;
	
	import flashx.undo.IOperation;
	
	/**
	 * 
	 * @author tangzhixu
	 * @date 2011-10-17
	 */	
	public class LockUIOperation extends OperationBase
	{
		private var data:UIInstanceInfo;
		
		public function LockUIOperation(data:UIInstanceInfo)
		{
			this.data = data;
		}
		
		override public function performRedo():void
		{
			uiMainContainer.lockUI(data);
		}
		
		override public function performUndo():void
		{
			uiMainContainer.lockUI(data);
		}
	}
}