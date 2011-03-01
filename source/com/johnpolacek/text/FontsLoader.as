﻿package com.johnpolacek.text{		import flash.display.Sprite;	import flash.display.Loader;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.TimerEvent;	import flash.net.URLRequest;	import flash.utils.Timer;	import flash.text.Font;	 /** * The FontsLoader class loads fonts for runtime use. * * @example  * <br /> * Load a single font: * <code> * var loader:FontsLoader = new FontsLoader(); * loader.addEventListener(Event.COMPLETE, onFontsLoadComplete); * loader.loadFont("fonts/GentiumFamily.swf"); * </code> * <br /> * Load multiple fonts: * <code> * var fontsArray:Array = new Array("fonts/GentiumFamily.swf","fonts/Andika.swf","fonts/GoodDog.swf"); * var loader:FontsLoader = new FontsLoader(); * loader.addEventListener(Event.COMPLETE, onFontsLoadComplete); * loader.loadFonts(fontsArray); * </code> *  * @version  * <b>19 Apr 2010</b>  Added error handling * <b>5 Apr 2010 </b> * * @author John Polacek, john@johnpolacek.com */	 		public class FontsLoader extends Sprite {				private var fonts = [];		private var fontsLoaded:int = 0;		private var timeOut:Timer;				public function FontsLoader() 		{			timeOut = new Timer(2000,0);			timeOut.addEventListener(TimerEvent.TIMER, onTimeOut);		}				/** Loads multiple fonts from an array of url strings that 		* each point to a swf that contains an embedded font (i.e. "arial.swf")	 	* 		* @param fonts An array of font url strings		*/	 		public function loadFonts(f:Array):void		{			fonts = f;			fontsLoaded = 0;			loadFont(fonts[0]);			timeOut.start();		}				/** Loads a single font from a url string points for swf 		* that contains an embedded font (i.e. "arial.swf")	 	* 		* @param fontURL URL of font swf		*/			public function loadFont(fontURL:String):void		{			trace("FontsLoader.loadFont: "+fontURL);			if (fonts.length == 0)				fonts = [fontURL]			var loader:Loader = new Loader();			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFontLoaded);			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFontLoadError);			loader.load(new URLRequest(fontURL));		}				public function onFontLoadError(event:IOErrorEvent):void		{			trace("Font "+fonts[fontsLoaded]+"not found. Font will not be loaded.");			onFontLoaded(null);		}				private function onFontLoaded(event:Event):void		{			fontsLoaded++;			if (fontsLoaded >= fonts.length)				onLoadComplete();			else				loadFont(fonts[fontsLoaded]);		}				private function onTimeOut(event:Event):void		{			trace("FontsLoader.onTimeOut "+fonts[fontsLoaded]);			fonts = fonts.slice(fontsLoaded);			if (fonts.length > 0)				loadFont(fonts[0])			else				onLoadComplete();		}				private function onLoadComplete():void		{			trace("FontsLoader.onLoadComplete --------------");			reset();			var embeddedFonts:Array = Font.enumerateFonts(false);			embeddedFonts.sortOn("fontName", Array.CASEINSENSITIVE);			trace("loaded "+embeddedFonts.length+" fonts");			for each (var font:Font in embeddedFonts) 			{				trace("Font Loaded: "+font.fontName);			}			dispatchEvent(new Event(Event.COMPLETE));		}				private function reset():void		{			fonts = [];			fontsLoaded = 0;			timeOut.stop();		}	}}