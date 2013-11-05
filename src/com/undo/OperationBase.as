package com.undo
{
	import com.main.UIMainContainer;
	
	import flashx.undo.IOperation;
	
	/**
	 * 
	 * @author tangzhixu
	 * @date 2011-10-17
	 */	
	public class OperationBase implements IOperation
	{
		protected var uiMainContainer:UIMainContainer = UIMainContainer.Instance;
		protected var layout:XMakeUI;
		public function config(main:XMakeUI):void
		{
			layout = main;
		}
		
		public function OperationBase()
		{
		}
		
		public function performRedo():void
		{
		}
		
		public function performUndo():void
		{
		}
	}
}