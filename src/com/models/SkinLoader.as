package com.models
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	/**
	 * 资源加载
	 */
	public class SkinLoader extends EventDispatcher
	{
		private var _data:UIInstanceInfo = null;
		private var _loader:Loader = new Loader();

		public var styleName:String = null;
		public var styleType:String = null;
		public var styleGrid:String = null;
		public var skinName:String = null;
		public var skinMethodName:String = null;

		public function SkinLoader(data:UIInstanceInfo, target:IEventDispatcher = null)
		{
			super(target);
			_data = data;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		}

		private function onIoError(event:IOErrorEvent):void
		{
			trace(event.text);
		}

		public function get loaderContent():DisplayObject
		{
			return this._loader.content;
		}

		public function dispose():void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadCompleteHandler);
			_loader = null;
			_data = null;
		}

		public function get data():UIInstanceInfo
		{
			return this._data;
		}

		public function loadSkin(url:String):void
		{
			_loader.load(new URLRequest(url));
		}

		private function onLoadCompleteHandler(evt:Event):void
		{
			this.dispatchEvent(new Event(Event.COMPLETE));
		}

	}
}