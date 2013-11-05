////////////////////////////////////////////////////////////////////////////////
//	显示可视化对象的矩阵box 
////////////////////////////////////////////////////////////////////////////////
package com.ui
{
	
import flash.display.DisplayObject;
import flash.display.Sprite;

/**
 * 显示可视化对象的矩阵列表
 */	
public class RectBox extends Sprite
{
	private var _viewList : Array = null;
	private var _widthSpace : Number = 5;
	private var _heightSpace : Number = 3;
	private var _amount : Number = 5;
	
	/**
	 * get RectBox中的数组
	 */	
	public function get viewList() : Array
	{
		return _viewList;
	}
	
	/**
	 * get RectBox的左右间距
	 */	
	public function get widthSpace():Number
	{
		return this._widthSpace;
	}
	
	/**
	 * get RectBox的上下间距
	 */	
	public function get heightSpace():Number
	{
		return this._heightSpace;
	}
	
	/**
	 * get RectBox一行的个数
	 */	
	public function get amount():Number
	{
		return this._amount;
	}
	
	
	public function RectBox(widthSpace:Number = 5 ,heightSpace:Number = 3,amount:Number = 5)
	{
		super();
		_widthSpace = widthSpace;
		_heightSpace = heightSpace;
		_amount = amount;
		
		_viewList = [];
	}
	
	override public function removeChildAt(index:int):DisplayObject
	{
		var obj:DisplayObject = super.removeChildAt(index);
		remove(obj);
		return obj;
	}
	
	/** 
	 * 摧毁
	 */	
	public function dispose():void
	{
		_viewList = null;
		while(Boolean(this.numChildren))
		{
			removeChildAt(0);
		}
	}
	
	/**
	 * 添加元素
	 */	
	override public function addChild(child:DisplayObject):DisplayObject
	{
		_viewList.push(child);
		layOut(_viewList.length - 1, child);
		super.addChild(child);
		return child;
	}	
	/** 
	 * box的长度
	 */	
	public function  get length():uint
	{
		return this._viewList.length;
	}
	
	public function removeAll():void
	{
		while(this.numChildren)
		{
			removeChildAt(0);
		}
		this._viewList = [];
	}
	/**
	 * 按照元素删除
	 */
	public function remove(obj:DisplayObject):void
	{
		var index:int = _viewList.indexOf(obj);
		if(index == -1)
		{
			throw(new Error("无法移出不在显示列表中的对象."));
		}
		_viewList.splice(index, 1);
		reflushView();
	}
	
	/**
	 * 按照索引删除
	 */	
	public function removeByIndex(index:uint):void
	{
		if(index > _viewList.length - 1)
		{
			throw(new Error("索引超出范围."));
		}
		_viewList.splice(index, 1);
		reflushView();
	}
	
	/** 
	 * 刷新box
	 */	
	public function reflushView():void
	{
		while(Boolean(this.numChildren))
		{
			super.removeChildAt(0);
		}

		var len:uint = _viewList.length
		var obj:DisplayObject = null;
		for(var i:int = 0; i < len; i++) 
		{
			obj = DisplayObject(_viewList[i] );
			super.addChild(obj);
			this.layOut(i, obj);	
			//obj.x = (obj.width + _widthSpace) * (i % _amount);
			//obj.y = (obj.height + _heightSpace) * int(i / _amount);
		}
	} 
	
	private function layOut(len:uint, obj:DisplayObject):void
	{
		var pos:int = len;
		var posX:uint = pos  % _amount;
		var posY:uint = Math.floor(pos / _amount);
		
		obj.x = (obj.width + _widthSpace) * posX;
		obj.y = (obj.height + _heightSpace) * posY;
	}
	
  
	}
}