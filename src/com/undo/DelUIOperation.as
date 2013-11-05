package com.undo
{
	import com.models.UIInstanceInfo;

	/**
	 * 
	 * @author tangzhixu
	 * @date 2011-10-19
	 */	
	public class DelUIOperation extends OperationBase
	{
		private var instance:UIInstanceInfo;
		
		public function DelUIOperation(instance:UIInstanceInfo)
		{
			super();
			this.instance = instance;
		}
		
		override public function performUndo():void
		{
			uiMainContainer.isUndoManagerProcess = true;
			uiMainContainer.appendUI(instance);
			uiMainContainer.isUndoManagerProcess = false;
		}
		
		override public function performRedo():void
		{
			uiMainContainer.isUndoManagerProcess = true;
			uiMainContainer.deleteUI(instance, false);
			uiMainContainer.isUndoManagerProcess = false;
		}
	}
}