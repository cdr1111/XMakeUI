package com.undo
{
	import com.models.UIInstanceInfo;
	import com.structurals.StyleData;
	
	import flash.display.DisplayObject;

	/**
	 * 
	 * @author tangzhixu
	 * @date 2011-10-19
	 */	
	public class ChangeStyleOperation extends OperationBase
	{
		public var instance:UIInstanceInfo, styleData:StyleData, skinName:String, type:String, skin:DisplayObject;
		public var oldSkinName:String,
		oldType:String,
		oldSkin:*;
		
		public function ChangeStyleOperation(instance:UIInstanceInfo,
											 styleData:StyleData,
											 skinName:String,
											 type:String, 
											 skin:DisplayObject,
											 oldSkinName:String,
											 oldType:String,
											 oldSkin:*)
		{
			super();
			this.instance = instance;
			this.styleData = styleData;
			this.skinName = skinName;
			this.type = type;
			this.skin = skin;
			this.oldSkinName = oldSkinName;
			this.oldType = oldType;
			this.oldSkin = oldSkin;
		}
		
		override public function performUndo():void
		{
			uiMainContainer.isUndoManagerProcess = true;
			uiMainContainer.changeSkin(instance, styleData, oldSkinName, oldType, oldSkin);
			uiMainContainer.isUndoManagerProcess = false;
		}
		
		override public function performRedo():void
		{
			uiMainContainer.isUndoManagerProcess = true;
			uiMainContainer.changeSkin(instance, styleData, skinName, type, skin);
			uiMainContainer.isUndoManagerProcess = false;
		}
	}
}