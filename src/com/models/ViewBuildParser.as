package com.models
{
	import com.enum.TypeEnum;
	import com.tools.TypeConversion;
	
	import flash.display.DisplayObject;
	
	/**
	 * 数据解析
	 */ 
	public class ViewBuildParser
	{
		public function ViewBuildParser()
		{
			
		}
		/**
		 * 解析XML 获得一个创建的实例
		 */ 
		public function parseUI(xml:XML):UIInstanceInfo
		{
			var ui:UIInstanceInfo = new UIInstanceInfo();
			var cls:Class = UIModelInfo.Instance.appDomain.getDefinition(xml.@fullName) as Class;		
			ui.displayObj = new cls();
			ui.displayObj.name = xml.@instanceName;
			ui.infoXML = xml;
			updateView(ui.infoXML, ui.displayObj);
			return ui;
		}
		/** 
		 * 更新ui  
		 */ 
		public function updateView(xml:XML, view:DisplayObject):void
		{
			var i:int = 0;
			var len:int = xml.Properties.Propertie.length();
			for(i = 0; i < len; i++)
			{
				var xmlList:XML = xml.Properties.Propertie[i] as XML;
				
				var value:String = xmlList.@value.toString();
				
				var type:String = xmlList.@type.toString();
				
				if(value == "")
				{
					if(type == TypeEnum.int || type == TypeEnum.number || type == TypeEnum.uint)
					{
						view[xmlList.@name] = null;
						continue; 
					}
					else
				    {
						view[xmlList.@name] = TypeConversion.convert(value, type);		
					}		
				
				}	
				view[xmlList.@name] = TypeConversion.convert(value, type);			
			}
		}
	
		
	}
}