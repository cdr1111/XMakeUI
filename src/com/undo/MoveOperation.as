package com.undo
{
	import com.models.UIInstanceInfo;
	
	import flash.geom.Point;
	
	/**
	 * 移动操作
	 * @author tangzhixu
	 * @date 2011-10-17
	 */	
	public class MoveOperation extends OperationBase
	{
		private var target:UIInstanceInfo;
		private var start:Point;
		private var end:Point;
		
		public function MoveOperation(target:UIInstanceInfo, start:Point, end:Point)
		{
			this.target = target;
			this.start = start;
			this.end = end;
		}
		
		override public function performRedo():void
		{
			target.displayObj.x = end.x;
			target.displayObj.y = end.y;
			layout.propertyPanel.updateAttributeFromUI();
		}
		
		override public function performUndo():void
		{
			target.displayObj.x = start.x;
			target.displayObj.y = start.y;
			layout.propertyPanel.updateAttributeFromUI();
		}
	}
}