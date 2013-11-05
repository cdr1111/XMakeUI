////////////////////////////////////////////////////////////////////////////////////////////////////
//									转化一个 显示对象为 位图模式 以减少渲染开销
////////////////////////////////////////////////////////////////////////////////////////////////////
package com.tools
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
public class ConvertAsBitmap
{
	/**
	 * 转化 一个 DisplayObject 为 Bitmap
	 */
	public static function convert(child:DisplayObject, transparent:Boolean = true):Bitmap
	{
		var width:Number = int(child.width);
		var height:Number = int(child.height);
		
		/**
		 * 开始使用BitmapData转化位图
		 */
		var bmpData:BitmapData = new BitmapData(width, height , transparent, 0);
		bmpData.draw(child);
		var bmp:Bitmap = new Bitmap(bmpData);
		
		return bmp;
	}
}
}