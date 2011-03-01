﻿package com.johnpolacek.application{	import flash.display.BlendMode;	import flash.display.DisplayObject;	import flash.display.Loader;	import flash.display.MovieClip;	import flash.display.SimpleButton;	import flash.display.Sprite;	import flash.display.StageDisplayState;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.events.IOErrorEvent;	import flash.events.MouseEvent;	import flash.events.ProgressEvent;	import flash.media.SoundMixer;	import flash.net.navigateToURL;	import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.text.Font;	import flash.text.StaticText;	import flash.text.StyleSheet;	import flash.text.TextField;	import flash.text.TextFormat;	import flash.text.TextFormatAlign;	import flash.ui.Keyboard;	import com.google.analytics.AnalyticsTracker; 	import com.google.analytics.GATracker;	import com.greensock.TweenLite;	import com.greensock.easing.Expo;	import com.greensock.plugins.TweenPlugin;	import com.greensock.plugins.AutoAlphaPlugin; 	import com.johnpolacek.animation.PreloadAnimationSquares;	import com.johnpolacek.components.ContentContainer;	import com.johnpolacek.components.Lightbox;	import com.johnpolacek.components.LightboxContentInfo;	import com.johnpolacek.display.ContentDisplay;	import com.johnpolacek.display.ContentDisplayCreator;	import com.johnpolacek.events.LightboxEvent;	import com.johnpolacek.events.UIEvent;	import com.johnpolacek.media.VideoStreamPlayer;	import com.johnpolacek.shapes.ArrowHead;	import com.johnpolacek.shapes.Frame;	import com.johnpolacek.shapes.Line;	import com.johnpolacek.shapes.RectangleShape;	import com.johnpolacek.text.FontsLoader;	import com.johnpolacek.text.HTMLTextBlock;	import com.johnpolacek.ui.BasicButtonMenu;	import com.johnpolacek.ui.Scrollbar;	import com.johnpolacek.utils.StringUtils;		 /** * A flash site template that supports importing external swf's that have * been generated from InDesign. Lightbox functionality is enabled by  * adding Interactive Buttons in InDesign and adding the file names of  * the content to be lightboxed to the button title. * * Button handling has been configured specifically to work with * swf's generated from InDesign.  *  * @version  * <b>20 Apr 2010</b> * @author John Polacek, john@johnpolacek.com */	 		public class BriefingRoom extends MovieClip	{						// display objects		private var background:Sprite = new Sprite();		private var pagesContainer:Sprite = new Sprite();		private var header:Sprite = new Sprite();		private var footer:Sprite = new Sprite();		private var masthead:ContentContainer;		private var footerContent:ContentContainer;		private var bug:ContentDisplay;		private var prevButton:Sprite;		private var nextButton:Sprite;		private var nav:BriefingRoomNav;		private var scrollbar:Scrollbar;		private var lightbox:Lightbox;		private var loadingTextField:TextField = new TextField();		private var preloadAnimation:PreloadAnimationSquares;				// formatting		private var format:BriefingRoomFormat;		private var contentPath:String;				// content		private var briefingXML:XML;		private var pagesXML:XML;		private var contentCreator = new ContentDisplayCreator();		private var currPage:int;		private var currSection:int;		private var numPages:int;		private var numSourceFiles:int;		private var pagesLoaded:int;		private var maxScroll:int;		private var sections = [];				// tracking		private var tracker:AnalyticsTracker;		private var trackingCode:String;				private var projectorScale:Number = 1; // width of the stage before entering full screen mode		private var projectorMode:Boolean;				public function BriefingRoom()		{			trace("BriefingRoom");			addChild(background);			addChild(pagesContainer);			addChild(header);			addChild(footer);						pagesContainer.visible = false;						addEventListener(UIEvent.BUTTON_SELECT, onButtonSelect);			addEventListener(UIEvent.DROPDOWN_SELECT, onDropdownSelect);			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);						TweenPlugin.activate([AutoAlphaPlugin]);						// Set Projector Mode			var baseWidth:Number = stage.stageWidth;			try			{				stage.displayState = StageDisplayState.FULL_SCREEN;				projectorScale = baseWidth / stage.stageWidth;				projectorMode = true;			}			catch (e:SecurityError) 			{ 				// if not running in projector mode, going full screen without a mouse click is not allowed				projectorMode = false;			}									loadXML();		}			//--------------------------------------------------------------------------    //    //  Sequenced Loading & Building    //    //--------------------------------------------------------------------------			//----------------------------------  	//  MAIN XML   	//----------------------------------				private function loadXML():void		{			// load briefing.xml first, contains all general formatting information for the template			var loader:URLLoader = new URLLoader(); 			loader.addEventListener(Event.COMPLETE, onXMLLoadComplete); 			// add random number query to end of url to clear cache			loader.load(new URLRequest("briefing.xml" + "?rand=" + Math.random())); 		}				private function onXMLLoadComplete(event:Event):void		{			briefingXML = XML(event.target.data);			contentPath = contentCreator.contentPath = briefingXML.content.directory;			format = new BriefingRoomFormat(briefingXML);			background.addChild(new RectangleShape(format.roomWidth, format.roomHeight, format.backgroundColor));						//display preload animation			preloadAnimation = new PreloadAnimationSquares();			preloadAnimation.x = format.roomWidth/2;			preloadAnimation.y = format.roomHeight/2;			addChild(preloadAnimation);			preloadAnimation.start();						loadCSS();		}			//----------------------------------  	//  FONTS + CSS   	//----------------------------------				private function loadCSS():void		{			// styles.css contains styling for all HTMLTextBlock objects, but not non-html text objects			var loader:URLLoader = new URLLoader(); 			loader.addEventListener(Event.COMPLETE, onCSSLoadComplete); 			loader.load(new URLRequest("styles.css" + "?rand=" + Math.random()));		}				private function onCSSLoadComplete(event:Event):void		{			loadFonts();			format.textStyleSheet = new StyleSheet();    		format.textStyleSheet.parseCSS(event.target.data);		}				// loads external runtime fonts		private function loadFonts():void		{			var fonts:Array = [];			for each (var fontURL:String in format.fonts) 			{				fonts.push(fontURL);			}					if (fonts.length > 0)			{				var loader:FontsLoader = new FontsLoader();				loader.addEventListener(Event.COMPLETE, onFontsLoadComplete);				loader.loadFonts(fonts);						}			else			{				onFontsLoadComplete();			}		}				private function onFontsLoadComplete(event:Event = null):void		{			loadRuntimeAssets();		}				private function loadRuntimeAssets():void		{			var loader:Loader = new Loader();			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRuntimeAssetsLoadComplete);			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onRuntimeAssetsLoadError);			loader.load(new URLRequest("runtime.swf"));		}				public function onRuntimeAssetsLoadError(event:IOErrorEvent):void		{			trace("No runtime assets to load: runtime.swf not found");			onRuntimeAssetsLoadComplete();		}				private function onRuntimeAssetsLoadComplete(event:Event = null):void		{			// load pages xml			var loader:URLLoader = new URLLoader(); 			loader.addEventListener(Event.COMPLETE, onPagesXMLLoadComplete); 			loader.load(new URLRequest("pages.xml" + "?rand=" + Math.random()));		}			//----------------------------------  	//  PAGES XML   	//----------------------------------				// The pages xml file contains the formatting for the page content		private function onPagesXMLLoadComplete(event:Event):void		{			pagesXML = XML(event.target.data);						// tracking			trackingCode = pagesXML.tracking.code;			initTracking();						preloadAnimation.finish();						createHeader();			//buildPages();		}			//----------------------------------  	//  HEADER   	//----------------------------------				private function createHeader():void		{			if (String(pagesXML.masthead) != "")			{				// create masthead				masthead = new ContentContainer(0)				masthead.textStyleSheet = format.textStyleSheet;				masthead.loadContentFromXML(XML(pagesXML.masthead));				masthead.addEventListener(Event.COMPLETE, onMastheadLoadComplete);				masthead.mouseChildren = false;				masthead.buttonMode = true;				//masthead.addEventListener(MouseEvent.MOUSE_DOWN, onMastheadClick);								// add line				var headerLine:Line = new Line(format.roomWidth, 1, uint(format.lineColor));				headerLine.y = briefingXML.header.height;				header.addChild(headerLine);				TweenLite.from(headerLine, 1, {alpha:0});			}			else			{				onMastheadComplete();			}		}				private function onMastheadLoadComplete(event:Event):void		{			trace("BriefingRoom.onMastheadComplete");			masthead.x = int(pagesXML.masthead.@x) + int(briefingXML.pages.margin);			masthead.y = int(pagesXML.masthead.@y);			header.addChild(masthead);			TweenLite.from(masthead, .5, {alpha:0});			onMastheadComplete();		}				private function onMastheadComplete():void		{			createFooter();		}			//----------------------------------  	//  FOOTER   	//----------------------------------				private function createFooter():void		{			// add line			var footerLine:Line = new Line(format.roomWidth, 1, format.lineColor);			footer.y = int(briefingXML.header.height) + int(briefingXML.pages.height);			footer.addChild(footerLine);			TweenLite.from(footerLine, 1, {alpha:0, delay:.5});						// create bug			if (String(briefingXML.footer.bug) != "")			{				bug = contentCreator.create(briefingXML.footer.bug);				bug.addEventListener(Event.COMPLETE, onBugComplete);			}			else			{				loadFooter();			}		}				private function onBugComplete(event:Event):void		{			bug.x = 1;			bug.y = footer.y + int(briefingXML.footer.height) - bug.height;			loadFooter();		}				private function loadFooter():void		{			if (String(pagesXML.footer) != "")			{				footerContent = new ContentContainer(0)				footerContent.textStyleSheet = format.textStyleSheet;				footerContent.loadContentFromXML(XML(pagesXML.footer));				footerContent.addEventListener(Event.COMPLETE, onFooterContentComplete);				}			else			{				onFooterComplete();			}		}				private function onFooterContentComplete(event:Event):void		{			footerContent.x = format.roomWidth - footerContent.width - int(briefingXML.pages.margin);			footerContent.y = format.scrollbar.height +2;			footer.addChild(footerContent);			TweenLite.from(footerContent, .5, {alpha:0});			onFooterComplete();		}				private function onFooterComplete():void		{			buildPages();		}			//----------------------------------  	//  PAGES   	//----------------------------------				private function buildPages():void		{			var pagesMask:Sprite = new RectangleShape(briefingXML.pages.width, briefingXML.pages.height);			addChild(pagesMask);			pagesContainer.x = pagesMask.x = int(briefingXML.pages.margin);			pagesContainer.y = pagesMask.y = int(briefingXML.header.height);			pagesContainer.mask = pagesMask;						// load Pages			numSourceFiles = pagesXML..source.length();			loadingTextField.width = briefingXML.pages.width;			addChild(loadingTextField);			loadingTextField.x = pagesContainer.x;			loadingTextField.y = briefingXML.pages.height/2;			loadingTextField.embedFonts = true;			var loadingTextFormat = new TextFormat(String(briefingXML.preloader.font), 														  int(briefingXML.preloader.size), 														  uint(briefingXML.preloader.color));			loadingTextFormat.align = TextFormatAlign.CENTER;			loadingTextField.defaultTextFormat = loadingTextFormat;			loadingTextField.blendMode = BlendMode.LAYER;			TweenLite.from(loadingTextField, 1, {alpha:0, delay:.5});			loadPageSource(0);		}				private function loadPageSource(i:int):void		{			var loader:Loader = new Loader();			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,showProgress);			var pageSourceURL:String = pagesXML.source[i];			loader.load(new URLRequest(pageSourceURL));			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPageSourceLoadComplete);					}				function showProgress(event:ProgressEvent):void 		{			loadingTextField.text = "LOADING ASSETS: "+ Math.round(((event.bytesLoaded / event.bytesTotal) * 100) / numSourceFiles)+ "%";		}				private function onPageSourceLoadComplete(event:Event):void		{			var swf:MovieClip = event.currentTarget.content;				formatPages(swf);		}				private function formatPages(mc:MovieClip):void		{			mc.addEventListener(Event.ENTER_FRAME, addPageFromFrame);		}				private function addPageFromFrame(event:Event):void		{			trace("BriefingRoom.addPageFromFrame");						var swf:MovieClip = MovieClip(event.target);			var page:MovieClip = MovieClip(swf.getChildAt(0));						// Aign page to end of pagesContainer			page.x = pagesContainer.numChildren * briefingXML.pages.width;						// Listener to detect button links			page.addEventListener(MouseEvent.MOUSE_DOWN, onPageButtonClick);						var pageChildren = [];			for (var i:int = 0; i < page.numChildren; i++)			{				pageChildren.push(page.getChildAt(i));			}			// cycle through children to format buttons			for each (var child in pageChildren) 			{				// catch buttons nested in MovieClips				if (child is MovieClip)				{					var mcChildren = [];					var j:int = 0;					for (j = 0; j < child.numChildren; j++)					{						mcChildren.push(child.getChildAt(j));					}					for each (var mcChild in mcChildren)					{						if (mcChild is SimpleButton)							formatSimpleButton(mcChild);					}				}				// format all SimpleButtons on page				if (child is SimpleButton)					formatSimpleButton(child);			}			pagesContainer.addChild(page);						loadingTextField.text = "LOADING PAGES: " + swf.currentFrame + "/" +swf.totalFrames;						if (swf.currentFrame == swf.totalFrames)			{				swf.removeEventListener(Event.ENTER_FRAME, addPageFromFrame);				onPageFormattingComplete();			}			swf.nextFrame();						// Nested Function to create BriefingRoom buttons from InDesign-generated SimpleButtons 			function formatSimpleButton(btn:SimpleButton):void			{				// use the button's upstate to get at the text in the SimpleButton				var upState:MovieClip = MovieClip(btn.upState);				var fieldLabel:String = "";				// loop through the upstate to get the StaticText objects				// and add the text to the fieldLabel string				for (var i:int = 0; i < upState.numChildren; i++)				{					if (upState.getChildAt(i) is StaticText)					{						var lineOfText:String = StaticText(upState.getChildAt(i)).text;						// remove the space that InDesign adds to the start of line breaks						if (lineOfText.charAt(0) == " ")							lineOfText = lineOfText.substr(1);						fieldLabel += lineOfText;					}				}				trace("BriefingRoom.formatSimpleButton  fieldLabel: "+fieldLabel);				// use fieldLabel string to format sections and create lightbox buttons				if (fieldLabel != "")				{					if (fieldLabel.indexOf("sec:") != -1)					{						// create new section						var section = {};						section.name = fieldLabel.substring(fieldLabel.indexOf(":")+1);						section.startPage = pagesContainer.numChildren +1;						section.subsections = [];						sections.push(section);						btn.visible = false;					}					if (fieldLabel.indexOf("sub:") != -1)					{						// create new subsection						var subsection = {};						subsection.name = fieldLabel.substring(fieldLabel.indexOf(":")+1);						subsection.startPage = pagesContainer.numChildren;						subsection.subsections = [];						sections[sections.length - 1].subsections.push(subsection);						btn.visible = false;					}					if (fieldLabel.indexOf("vid:") != -1)					{						// create video player						var videoURL:String = contentPath + fieldLabel.substring(fieldLabel.indexOf(":")+1);						var video:VideoStreamPlayer = new VideoStreamPlayer();						video.x = btn.x;						video.y = btn.y;						video.controlsOutside = true;						video.addController();						video.controls.scaleY = .75;						video.loadVideo(videoURL);						btn.parent.removeChild(btn);						page.addChild(video);					}					if (fieldLabel.indexOf("btn:") != -1)					{						var lightboxButton:Sprite = new RectangleShape(btn.width, btn.height);						lightboxButton.x = btn.x;						lightboxButton.y = btn.y;						lightboxButton.alpha = 0;						lightboxButton.buttonMode = true;						lightboxButton.useHandCursor = true;						lightboxButton.name = fieldLabel.substring(4);						btn.parent.addChild(lightboxButton);						btn.parent.removeChild(btn);					}				}				// END NESTED FORMAT SIMPLE BUTTON METHOD			}		}				private function onPageFormattingComplete():void		{					pagesLoaded++;			if (pagesLoaded < numSourceFiles)				loadPageSource(pagesLoaded);			else				onPagesLoadComplete();		}				private function onPagesLoadComplete():void		{			TweenLite.to(loadingTextField, 1, {autoAlpha:0, x:-(format.roomWidth/2), ease:Expo.easeInOut});			numPages = pagesContainer.numChildren;			createNav();			initLightbox();			initArrowButtons();			transitionPagesIn();			initScrolling();			if (bug)			{				addChild(bug);				TweenLite.from(bug, .5, {alpha:0});			}			track("Page View", "Page 1");			updateCurrSection();			if (String(briefingXML.frame!=""))			{											 				var frame:Frame = new Frame(format.roomWidth, format.roomHeight, uint(briefingXML.frame));				addChild(frame);				TweenLite.from(frame, 1, {alpha:0});			}			var embeddedFonts:Array = Font.enumerateFonts(false);			embeddedFonts.sortOn("fontName", Array.CASEINSENSITIVE);			trace("loaded "+embeddedFonts.length+" fonts");			for each (var font:Font in embeddedFonts) 			{				trace("Font Loaded: "+font.fontName);			}		}				private function transitionPagesIn():void		{			pagesContainer.visible = true;			var leftLine:Line = new Line(briefingXML.pages.height,										 1,										 uint(format.lineColor));			leftLine.rotation = 90;			leftLine.x = int(briefingXML.pages.margin);			leftLine.y = briefingXML.header.height;			addChild(leftLine);			var rightLine:Line = new Line(briefingXML.pages.height,										  1,										  uint(format.lineColor));			rightLine.rotation = 90;			rightLine.x = int(briefingXML.pages.margin) + int(briefingXML.pages.width);			rightLine.y = briefingXML.header.height;			addChild(rightLine);			TweenLite.from(pagesContainer, 1.5, {x:format.roomWidth, ease:Expo.easeInOut});			TweenLite.from(nextButton, .5, {alpha:0, delay:2});			TweenLite.from(leftLine, 1, {alpha:0, delay:2});			TweenLite.from(rightLine, 1, {alpha:0, delay:2});		}			//----------------------------------  	//  NAV   	//----------------------------------				private function createNav():void		{			var buttonTitles = [];			for each (var section in sections) 			{				buttonTitles.push(section.name);			}			nav = new BriefingRoomNav(buttonTitles, format);			nav.x = format.roomWidth - nav.width - (int(briefingXML.pages.margin) * 2) + int(briefingXML.header.buttons.@x);			nav.y = int(briefingXML.header.buttons.@y);			for (var i:int = 0; i < sections.length; i++)			{				if (sections[i].subsections.length > 0)				{					var dropdownTitles = []					for each (var subsection in sections[i].subsections)					{						dropdownTitles.push(subsection.name);					}					nav.addDropDown(dropdownTitles, i);				}			}			header.addChild(nav);		}						private function initArrowButtons():void		{			prevButton = createArrowButton();			nextButton = createArrowButton();			prevButton.rotation = 180;			prevButton.x = prevButton.width/2;			nextButton.x = int(briefingXML.pages.width) + nextButton.width/2 + int(briefingXML.pages.margin);			prevButton.y = nextButton.y = format.roomHeight/2;			addChild(prevButton);			addChild(nextButton);			prevButton.addEventListener(MouseEvent.MOUSE_DOWN, onPrevClick);			nextButton.addEventListener(MouseEvent.MOUSE_DOWN, onNextClick);						prevButton.visible = false;		}				private function createArrowButton():Sprite		{			var button:Sprite = new Sprite();			var buttonBackground:Sprite = new RectangleShape(int(briefingXML.pages.margin), int(briefingXML.pages.height)-2, format.backgroundColor, 1, 0, 0, 0, true);			buttonBackground.y += 1;			var arrowHead:Sprite = new ArrowHead(int(briefingXML.pages.margin)/3, int(briefingXML.pages.margin)/1.5, 3,  uint(briefingXML.pages.buttons), 1, true);			button.addChild(buttonBackground);			button.addChild(arrowHead);			button.alpha = .5;			button.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void { button.alpha = 1; });			button.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void { button.alpha = .5; });			button.buttonMode = true;			return button;		}			//----------------------------------  	//  LIGHTBOX   	//----------------------------------				private function initLightbox():void		{			lightbox = new Lightbox(format.lightboxFormat);			lightbox.contentPath = contentPath;			lightbox.projectorScale = projectorScale;			addChild(lightbox);			addEventListener(LightboxEvent.DISPLAY_CONTENT, onLightboxEvent);		}			//----------------------------------  	//  SCROLLING   	//----------------------------------				private function initScrolling():void		{			maxScroll = briefingXML.pages.width * (pagesContainer.numChildren - 1);			var scrollbarAdjust:int = 0;			if (bug)				scrollbarAdjust = bug.width;			scrollbar = new Scrollbar(format.roomWidth - scrollbarAdjust,									  format.scrollbar.scrubColor,									  format.scrollbar.scrubAlpha,									  format.scrollbar.trackColor,									  format.scrollbar.trackAlpha,									  format.scrollbar.height,									  60,									  false);			scrollbar.addEventListener(UIEvent.SCROLLBAR_MOVE, onScroll);			scrollbar.clickPercent = 1 / (numPages-1);			scrollbar.x = scrollbarAdjust;			scrollbar.y = 1;			footer.addChild(scrollbar);			TweenLite.from(scrollbar, 1, {alpha:0, scaleX:.05, ease:Expo.easeOut});		}			//--------------------------------------------------------------------------    //    //  Event Handlers    //    //--------------------------------------------------------------------------			//----------------------------------  	//  NAVIGATION   	//----------------------------------				private function onButtonSelect(event:UIEvent):void		{			var buttonIndex:int = event.value;			var pageIndex:int = int(sections[buttonIndex].startPage)-1;			scrollToPage(pageIndex);		}				private function onDropdownSelect(event:UIEvent):void		{			trace("BriefingRoom.onDropDownSelect "+event.value);			var sectionIndex:int = nav.menu.currButtonIndex;			var subsectionIndex:int = event.value;			scrollToPage(sections[sectionIndex].subsections[subsectionIndex].startPage);		}				/*private function onMastheadClick(event:MouseEvent):void		{			scrollToPage(0);		}*/				private function onKeyboard(event:KeyboardEvent):void		{			if (event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.PAGE_UP) 			{ 				onPrevClick(null);			} 						if (event.keyCode == Keyboard.RIGHT || event.keyCode == Keyboard.PAGE_DOWN) 			{ 				onNextClick(null);			} 		}				private function onPrevClick(event:MouseEvent):void		{			if (currPage != 0)				scrollToPage(currPage-1);		}				private function onNextClick(event:MouseEvent):void		{			if (currPage != numPages)				scrollToPage(currPage+1);			else				scrollToPage(currPage);		}			//----------------------------------  	//  SCROLLING   	//----------------------------------				private function scrollToPage(i:int):void		{			if (i > -1 && i < pagesContainer.numChildren)			{				var page:DisplayObject = pagesContainer.getChildAt(i);				scrollbar.doScroll(page.x/maxScroll);			}			else			{				trace("Page index "+i+"is not valid (out of range)");			}		}				private function onScroll(event:UIEvent):void		{			SoundMixer.stopAll();			var newX:Number = -(maxScroll * scrollbar.percent) + prevButton.width;			TweenLite.to(pagesContainer, .5, {x:newX, ease:Expo.easeOut, onComplete:onScrollComplete});		}				private function onScrollComplete():void		{			currPage = int(scrollbar.percent * numPages);			currSection = -1;			if (currPage > numPages-1)				currPage = numPages-1			updateCurrSection();			track("Page View", "Page "+(currPage+1));			prevButton.visible = (pagesContainer.x != prevButton.width);			nextButton.visible = (-pagesContainer.x + prevButton.width != maxScroll);						}				private function updateCurrSection():void		{			currSection = -1;			for (var i:int = 0; i < sections.length; i++)			{				if (currPage >= int(sections[i].startPage)-1)				{					currSection = i;				}			}			nav.menu.selectButton(currSection);			if (currSection != -1)				track("Section View", sections[currSection].name);		}			//----------------------------------  	//  LIGHTBOX   	//----------------------------------				private function onPageButtonClick(event:MouseEvent):void		{			trace("BriefingRoom.onPageButtonClick  "+event.target.name);			if (event.target is RectangleShape)			{				var buttonName:String = event.target.name;				var spaces:RegExp = /\s/g;				buttonName = buttonName.replace(spaces,"");				if (buttonName.indexOf("instance") == -1)				{					if (buttonName.indexOf("link:") != -1)					{						// if "link:" do relative url link						buttonName = buttonName.replace("link:","");						navigateToURL(new URLRequest(buttonName), "_blank");					}					else if (buttonName.indexOf("http://") != -1)					{						navigateToURL(new URLRequest(buttonName), "_blank");					}					else if (buttonName.indexOf(".txt") != -1)					{						var loader:URLLoader = new URLLoader(); 						loader.addEventListener(IOErrorEvent.IO_ERROR, onLightboxTextLoadError); 						loader.addEventListener(Event.COMPLETE, onLightboxTextLoadComplete); 						loader.load(new URLRequest(contentPath + buttonName)); 					}					else					{						displayLightboxContent(event.target.name);					}				}									track("Content View", buttonName);			}		}				private function onLightboxTextLoadError(event:Event):void		{			trace("Could not find linked text from page button");		}				private function onLightboxTextLoadComplete(event:Event):void		{			var lightboxTextLink:String = String(event.target.data);			var lightboxContentArray:Array = LightboxContentInfo.createContentArrayFromString(lightboxTextLink);			onLightboxEvent(new LightboxEvent(LightboxEvent.DISPLAY_CONTENT, lightboxContentArray));		}				private function displayLightboxContent(contentURL:String):void		{			trace("BriefingRoom.displayLightboxContent "+contentURL);			lightbox.displayContent(contentURL);		}				private function onLightboxEvent(event:LightboxEvent):void		{			lightbox.displayContent(event.contentInfo);			var contentURL:String = "";			for (var i:int = 0; i < event.contentInfo.length; i++)			{				if (i > 0)					contentURL += ",";				contentURL += event.contentInfo[i].url;			}			track("Content View", contentURL);		}	//--------------------------------------------------------------------------    //    //  Tracking    //    //--------------------------------------------------------------------------			private function initTracking() 		{			if (trackingCode != "" && !projectorMode) 			{				tracker = new GATracker(this, trackingCode, "AS3", false); 			}		}		private function track(trackAction:String, trackLabel:String = "") 		{			trace("TRACKING | "+pagesXML.title+" action:"+trackAction+" label:"+trackLabel);			if (tracker) 				tracker.trackEvent(pagesXML.title, trackAction, trackLabel);		}	}}