﻿package com.johnpolacek.application{		import flash.display.StageDisplayState;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.TextEvent;	import flash.net.URLLoader;	import flash.net.URLRequest;	import com.asual.SWFAddress;	import com.asual.SWFAddressEvent;	import com.johnpolacek.components.ContentPanel;	import com.johnpolacek.components.LightboxContentInfo;	import com.johnpolacek.shapes.RectangleShape;	 /** * An xml-based full-screen flash site template designed for showcasing creative works. *  * @version  * <b>02 Jun 2010</b>  <br>  * * @author John Polacek, john@johnpolacek.com */	 		public class ViewingRoom extends FullScreenSite	{				private var contentBackground:RectangleShape;		private var contentSelect:String = "";		private var roomXML:String = "";				public function ViewingRoom()		{					}				/** Header complete handler **/		override public function onHeaderLoadComplete(event:Event = null):void		{			trace("ViewingRoom.onHeaderComplete");			if (header.numChildren > 0)			{				container.addChild(header);				transitionHeaderIn();			}			addSectionContainer();			onStageResize(null);			initLightbox();		}				/** Adds content container **/		override public function addSectionContainer():void		{			trace("ViewingRoom.addSectionContainer");			sectionContainer.y = header.y + header.height;			container.addChild(sectionContainer);			loadSection();		}				/** Loads section 		*	@param sectionIndex Section index to load		**/		override public function loadSection(sectionIndex:int = 0):void		{			if (roomXML=="")				roomXML = siteXML.xml;			var section:ContentPanel = new ContentPanel();			section.styleSheet = format.textStyleSheet;			section.contentPath = format.contentPath;			section.setFormat(format.sectionFormat);			section.loadElementFromXML(roomXML); // the content panel loads the xml file and builds itself			section.addEventListener(Event.COMPLETE, onSectionLoadComplete);			section.visible = false;		}				/** Actions initiated after first section has loaded **/		override public function onSectionContainerLoadComplete(event:Event = null):void		{			trace("ViewingRoom.onSectionContainerLoadComplete");			contentBackground = new RectangleShape(format.sectionFormat.width, 0, format.sectionFormat.color);			contentBackground.y = sectionContainer.y;			container.addChildAt(contentBackground, 0);			onSiteLoadComplete();						if (String(siteXML.title) != "")				SWFAddress.setTitle(siteXML.title);		}				/** Stage resizing manager **/		override public function onStageResize(event:Event = null):void		{			if (stage.stageWidth > container.width + format.margin) 				container.x = (stage.stageWidth -  containerWidth + format.margin) / 2;			else 				container.x = format.margin;							if (contentBackground)				contentBackground.height = stage.stageHeight - header.height - header.y - 1;						if (scrollbar) 			{				scrollbar.x = stage.stageWidth - scrollbar.width;				scrollbar.visible = container.height + format.margin > stage.stageHeight;			}								if (background.numChildren > 0)				scaleBackgroundToStage();		}				/** Handles text link events (lightboxing) **/		override public function textLinkHandler(event:TextEvent):void		{			trace("ViewingRoom.textLinkHandler "+event.text);						if (event.text.indexOf("viewingroom{") != -1)			{				// if link is to another viewing room, change the url of the roomXML variable and reload				roomXML = event.text.slice(event.text.indexOf("{") + 1,event.text.indexOf("}"));				loadSection(0);			}			else if (event.text.indexOf("lightbox{") != -1)			{				// for lightboxing to elements with lots of properties (ie. title/subtitle/note text, formatting)				// use "set:mytextfile.txt" to link to a plain text file that contains the markup for the elements				if (event.text.indexOf("set:") == -1)				{					// if the lightbox link is NOT a set, create the content array from the event text 					var lightboxContentArray:Array = LightboxContentInfo.createContentArrayFromString(event.text);					lightbox.displayContent(lightboxContentArray);				}				else				{					// if the lightbox link IS a set, create the content array from the event text 					var loader:URLLoader = new URLLoader(); 					loader.addEventListener(IOErrorEvent.IO_ERROR, onLightboxTextLoadError); 					loader.addEventListener(Event.COMPLETE, onLightboxTextLoadComplete); 					contentSelect = ""; // clear contentSelect var										// if the event text has a url, the contentSelect var contains the content					// that is selected to be displayed from the linked set					if (event.text.indexOf("url:") != -1)					{						contentSelect = event.text.slice(event.text.indexOf("url:")+4);						if (contentSelect.indexOf("}") != -1)							contentSelect = contentSelect.slice(0, contentSelect.indexOf("}"));						if (contentSelect.indexOf(",") != -1 && contentSelect.indexOf(":") != -1)							contentSelect = contentSelect.slice(0, contentSelect.indexOf(","));						contentSelect = contentSelect.replace(new RegExp("\\s"),"g"); //removes whitespace					}										// get the file name of the text file					var textFileName:String = event.text.slice(event.text.indexOf("set:")+4);					if (textFileName.indexOf("}") != -1)						textFileName = textFileName.slice(0, textFileName.indexOf("}"));					if (textFileName.indexOf(",") != -1)						textFileName = textFileName.slice(0, textFileName.indexOf(","));										loader.load(new URLRequest(format.contentPath + textFileName)); 				}			}		}				/** Load handler for externally loaded text formatted with lightbox content info **/		override public function onLightboxTextLoadComplete(event:Event):void		{			var lightboxTextLink:String = String(event.target.data);			lightboxTextLink = lightboxTextLink.replace(new RegExp("\\t","g"),"");			lightboxTextLink = lightboxTextLink.replace(new RegExp("\\n","g"),"");			var lightboxContentArray:Array = LightboxContentInfo.createContentArrayFromString(lightboxTextLink);			if (contentSelect != "")				lightboxContentArray.unshift(contentSelect);			lightbox.displayContent(lightboxContentArray);		}	}}