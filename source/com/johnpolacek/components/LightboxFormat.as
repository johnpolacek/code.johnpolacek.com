﻿package com.johnpolacek.components {	import flash.text.Font;	import flash.text.TextFormat;			 /** * The LightboxFormat class represents formatting information.  *   * Use the LightboxFormat class to create specific formatting for Lightboxes.  *  * You must use the constructor new LightboxFormat() to create a TextFormat object  * before setting its properties. The Lightbox properties are set to default values  * so if you don't provide values for the properties, Lightboxes use their own  * default formatting. *  * @version  * <b>01 May 2010</b>  Can now add link text to bottom right of ImageDisplay content that has hyperlinks <br> * <b>30 Mar 2010</b>  LightboxFormat now uses TextFormat objects for Lightbox TextFields <br> * * @author John Polacek, john@johnpolacek.com */	 		public class LightboxFormat {				/** Width of lightbox. Default is 0 (size to stageWidth) **/		public var lightboxWidth:int = 0;		/** Height of lightbox. Default is 0 (size to stageWidth) **/		public var lightboxHeight:int = 0;		/** The color of the overlay background  Default: 0xFFFFFF	**/		public var backgroundColor:uint = 0xFFFFFF;		/** The transparency alpha value of the overlay background. Default: .9	**/		public var backgroundAlpha:Number = .9;		/** The color of the content window background. Default: 0xFFFFFF	**/		public var contentBackgroundColor:uint = 0xFFFFFF;		/** The color of the content window background. Default: 0xFFFFFF	**/		public var contentBackgroundAlpha:Number = 1;		/** The transparency alpha value of the content window dropshadow. Default:	.5 **/		public var dropShadowAlpha:Number = .5;		/** The margin (in pixels) surrounding the content in the content window. Default:	10 **/		public var margin:Number = 10;		/** The TextFormat for the title TextField.  **/		public var titleTextFormat:TextFormat;		/** The TextFormat for the subtitle TextField.  **/		public var subtitleTextFormat:TextFormat;		/** The TextFormat for the note TextField.  **/		public var noteTextFormat:TextFormat;		/** The TextFormat for the image link TextField.  **/		public var linkTextFormat:TextFormat;		/** The TextFormat for the audio title TextField.  **/		public var audioTitleTextFormat:TextFormat;		/** The TextFormat for the audio subtitle TextField.  **/		public var audioSubtitleTextFormat:TextFormat;		/** The color of the lightbox buttons. <font color="0x999"><i>Must not be white.</i> </font>. Default:	0x000000  **/		public var buttonColor:uint = 0x000000;		/** The size of the close button. Default: 30  **/		public var buttonSize:int = 24;		/** The color of the lightbox window nav text (i.e. 1 of 3). Default: 0x333333	**/		public var navTextFormat:TextFormat;		/** Adjustment (in pixels) of the x position of the lightbox window nav text. Default: 0	**/		public var navTextX:int = 2;		/** Adjustment (in pixels) of the y position of the lightbox window nav text. Default: 0	**/		public var navTextY:int = 2;				public function LightboxFormat() 		{			titleTextFormat = new TextFormat(null,18,0x000000);			subtitleTextFormat = new TextFormat(null, 12, 0x000000);			noteTextFormat = new TextFormat(null, 10, 0x333333);			navTextFormat = new TextFormat(null, 12, 0x333333);		}				/** Use xml file to set formatting **/		public function setFormatFromXML(xml:XML) 		{			if (String(xml.overlay.color)!="") 				backgroundColor = uint(xml.overlay.color);							if (String(xml.overlay.alpha)!="") 				backgroundAlpha = Number(xml.overlay.alpha);							if (String(xml.background.color)!="") 				contentBackgroundColor = uint(xml.background.color);							if (String(xml.background.alpha)!="") 				contentBackgroundAlpha = Number(xml.background.alpha);							if (String(xml.background.dropshadow)!="") 				dropShadowAlpha = Number(xml.background.dropshadow);							if (String(xml.buttons.color)!="") 				buttonColor = uint(xml.buttons.color);						titleTextFormat = new TextFormat(null,18,0x000000);			if (String(xml.text.title.font)!="") 				titleTextFormat.font = xml.text.title.font;							if (String(xml.text.title.size)!="") 				titleTextFormat.size = xml.text.title.size;							if (String(xml.text.title.color)!="") 				titleTextFormat.color = xml.text.title.color;							if (String(xml.text.title.style)=="italic") 				titleTextFormat.italic = true;					subtitleTextFormat = new TextFormat(null, 12, 0x000000);			if (String(xml.text.subtitle.font)!="") 				subtitleTextFormat.font = xml.text.subtitle.font;							if (String(xml.text.subtitle.size)!="") 				subtitleTextFormat.size = xml.text.subtitle.size;							if (String(xml.text.subtitle.color)!="") 				subtitleTextFormat.color = xml.text.subtitle.color;							if (String(xml.text.subtitle.style)=="italic") 				subtitleTextFormat.italic = true;							noteTextFormat = new TextFormat(null, 10, 0x333333);			if (String(xml.text.note.font)!="") 				noteTextFormat.font = xml.text.note.font;							if (String(xml.text.note.size)!="") 				noteTextFormat.size = xml.text.note.size;							if (String(xml.text.note.color)!="") 				noteTextFormat.color = xml.text.note.color;							if (String(xml.text.note.style)=="italic") 				noteTextFormat.italic = true;							linkTextFormat = new TextFormat(null, 12, 0x000000);			if (String(xml.text.link.font)!="") 				linkTextFormat.font = xml.text.link.font;							if (String(xml.text.link.size)!="") 				linkTextFormat.size = xml.text.link.size;							if (String(xml.text.link.color)!="") 				linkTextFormat.color = xml.text.link.color;							if (String(xml.text.link.style)=="italic") 				linkTextFormat.italic = true;							navTextFormat = new TextFormat(null,12,0x333333);			if (String(xml.text.nav.font)!="") 				navTextFormat.font = xml.text.nav.font;							if (String(xml.text.nav.size)!="") 				navTextFormat.size = xml.text.nav.size;							if (String(xml.text.nav.color)!="") 				navTextFormat.color = xml.text.nav.color;							if (String(xml.text.nav.style)=="italic") 				navTextFormat.italic = true;							navTextX = int(xml.text.nav.offsetx);			navTextY = int(xml.text.nav.offsety);						audioTitleTextFormat = new TextFormat(null,14,0xFFFFFF);			if (String(xml.text.audiotitle.font)!="") 				audioTitleTextFormat.font = xml.text.audiotitle.font;							if (String(xml.text.audiotitle.size)!="") 				audioTitleTextFormat.size = xml.text.audiotitle.size;							if (String(xml.text.audiotitle.color)!="") 				audioTitleTextFormat.color = xml.text.audiotitle.color;								if (String(xml.text.audiotitle.style)=="italic") 				audioTitleTextFormat.italic = true;							audioSubtitleTextFormat = new TextFormat(null, 12, 0xAAAAAA);			if (String(xml.text.audiosubtitle.font)!="") 				audioSubtitleTextFormat.font = xml.text.audiosubtitle.font;							if (String(xml.text.audiosubtitle.size)!="") 				audioSubtitleTextFormat.size = xml.text.audiosubtitle.size;							if (String(xml.text.audiosubtitle.color)!="") 				audioSubtitleTextFormat.color = xml.text.audiosubtitle.color;							if (String(xml.text.audiosubtitle.style)=="italic") 				audioSubtitleTextFormat.italic = true;		}	}}