package com.tools
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	public class DragCheck
	{
		
		public function DragCheck()
		{
			super();
		}
		/**
		 * 传入一个显示容器 还有一个当前鼠标点（X，Y）
		 */ 
		public static function checkContainer(obj:DisplayObjectContainer, hit:DisplayObject):DisplayObject
		{
			var findChild:DisplayObject = null;
			var len:uint = obj.numChildren ; 
			var i:int = 0;
			for(i = len; i > 0; i--)
			{
				var child:DisplayObject = obj.getChildAt(i - 1);
				if(hit.hitTestObject(child) == true)
				{
					if(child is DisplayObjectContainer && child != hit)
					{
						findChild = child;
						break;
					}		
				}
			}
			return findChild;
		}
		/**
		 * 检查对象是否在鼠标的点上
		 */ 
		private static function checkPonitInObj(obj:DisplayObject, x:Number, y:Number):Boolean
		{
			var point:Point = obj.globalToLocal(new Point(0, 0) );
			var result1:Boolean = x < (Math.abs(point.x) + obj.width) && x > Math.abs(point.x);
			var result2:Boolean = y < (Math.abs(point.y) + obj.height) && y > Math.abs(point.y);
			var result3:Boolean = obj.parent != null;
			return (result1 && result2 && result3);
		}
		
		
	}
}