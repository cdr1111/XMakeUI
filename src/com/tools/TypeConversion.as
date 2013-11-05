package com.tools
{
	import com.enum.TypeEnum;
	import com.main.UIMainContainer;
	
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class TypeConversion
	{		
		/**
		 * 如果是数组的话 
		 */ 
		public static function convert(value:String, type:String, split:String = ":"):*
		{	
			var obj:* = null;
			switch(type)
			{
				case TypeEnum.bool:
				obj = value == "true";
				break;
				
				case TypeEnum.array:
				obj = value.split(split);
				break;
				
				case TypeEnum.int:
				obj = int(value);
				break;
				
				case TypeEnum.uint:
				obj = uint(value);
				break;
				
				case TypeEnum.number:
				obj = Number(value);
				break;
				
				case TypeEnum.string:
				obj = value;
				break;	
				
				case TypeEnum.displayObject:
				obj = DisplayObject(value);
				break;
				
				case TypeEnum.font:
				obj = getTextFomatByConfig(value);
				break;
			}
			return obj;	
		}
		
		
		private static function getTextFomatByConfig(value:String):TextFormat
		{
			var tf:TextFormat = UIMainContainer.Instance.defaultFont;
			var fonts:Array = value.split("|");
			if (fonts.length > 1 && value != "null|null|null|null|null")
			{
				if(fonts[0] == TextFormatAlign.LEFT ||
					fonts[0] == TextFormatAlign.RIGHT ||
					fonts[0] == TextFormatAlign.CENTER ||
					fonts[0] == TextFormatAlign.JUSTIFY)
					tf.align = String(fonts[0]);
				
				tf.bold = fonts[1] == "true";
				tf.color = uint(fonts[2]);
				tf.font = String(fonts[3]);
				tf.size = uint(fonts[4]);
				if (fonts.length >= 6)
				{
					tf.italic = fonts[5] == "true";
					tf.leading = uint(fonts[6]);
					tf.underline = fonts[7] == "true";
					tf.letterSpacing = uint(fonts[8]);
				}
			}
			else
				tf = UIMainContainer.Instance.defaultFont;
			
			/*var tf:TextFormat = new TextFormat();
			var fonts:Array = value.split("|");
			tf.align = String(fonts[0]);
			tf.bold = fonts[1] == "true";
			tf.color = uint(fonts[2]);
			tf.font = String(fonts[3]);
			tf.size =  uint(fonts[4]);	 
			if(fonts.length >= 6)
			{
				tf.italic = fonts[5] == "true";
				tf.leading = uint(fonts[6]);
				tf.underline = fonts[7] == "true";
				tf.letterSpacing = uint(fonts[8]);;	
			}*/
			return tf;
		}
	}
}