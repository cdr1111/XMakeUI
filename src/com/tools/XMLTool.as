package com.tools
{

	/**
	 * 组装XML 
	 */ 
	public class XMLTool
	{
		private var _xml:String = "";
		private var _name:String = null;
		private var _attribute:String = "";
		private var _content:String = "";
		public function XMLTool(root:String = "root")
		{
			_name = root;
		}
		
		public function addPropertie(keyName:String, value:String):void
		{
			var char:String = " " + keyName + "=\"" + value + "\"";
			_attribute += char;
		}
		
		public function addContent(content:String):void
		{
			_content += content;
		}
		
		public function toXml():XML
		{
			return new XML(toString() );
		}
		
		public function toString():String
		{	
			if(_content == "")
			{
				_xml = "<" + _name + _attribute + "/>";
			}
			else
			{
				_xml = "<" + _name + _attribute + ">";
				_xml += _content;
				_xml += "</" + _name + ">";
			}
			return _xml;
		}
	}
}