package com.undo
{
	import flashx.undo.IOperation;
	import flashx.undo.UndoManager;
	
	/**
	 * 
	 * @author tangzhixu
	 * @date 2011-10-17
	 */	
	public class UIUndoManager extends UndoManager
	{
		[Bindable]
		public var undoable:Boolean;
		[Bindable]
		public var redoable:Boolean;
		[Bindable]
		public var hasOperation:Boolean;
		
		public var main:XMakeUI;
		
		public function UIUndoManager()
		{
			super();
		}
		
		private function updateRU():void
		{
			undoable = canUndo();
			redoable = canRedo();
			hasOperation = undoable || redoable;
		}
		
		override public function clearAll():void
		{
			super.clearAll();
			updateRU();
		}
		
		override public function pushRedo(operation:IOperation):void
		{
			super.pushRedo(operation);
			updateRU();
		}
		
		override public function pushUndo(operation:IOperation):void
		{
			super.pushUndo(operation);
			clearRedo();
			updateRU();
		}
		
		override public function redo():void
		{
			if (canRedo())
			{
				var redoOp:IOperation = popRedo();
				OperationBase(redoOp).config(main);
				redoOp.performRedo();
				super.pushUndo(redoOp);
				updateRU();
			}
		}
		
		override public function undo():void
		{
			if (canUndo())
			{
				var undoOp:IOperation = popUndo();
				OperationBase(undoOp).config(main);
				undoOp.performUndo();
				pushRedo(undoOp);
				updateRU();
			}
		}
	}
}