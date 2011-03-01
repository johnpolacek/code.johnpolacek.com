﻿// IMPORTANT: REQUIRES crossdomain.xml ON TOP LEVEL OF DOMAIN// If security error is still thrown, check for new policy file on twimg.com subdomainpackage com.johnpolacek.widgets {	import flash.display.Sprite;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.geom.ColorTransform;	import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.net.URLRequestMethod;	import flash.system.Security;	import flash.text.StyleSheet;	import com.johnpolacek.display.ImageDisplay;	import com.johnpolacek.events.UIEvent;	import com.johnpolacek.shapes.Line;	import com.johnpolacek.text.HTMLTextBlock;		public class TwitterSearchResultContainer extends Sprite {		public var tweetStyleSheet:StyleSheet;		public var tweets:Array = [];		public var pics:Array = [];		public var times:Array = [];		public var authors:Array = [];		public var proxyURL:String;		public var searchURL:String;		public var loader:URLLoader;		public var tweetsLoaded:int = 0;		public var tweetY:int = 0;				public static const TWITTER_BADGE_URL:String = 			"http://images1.wikia.nocookie.net/__cb20091014062441/uncyclopedia/images/a/ae/Twitter-48x48.png";		public function TwitterSearchResultContainer(proxy:String) 		{			trace("NOTE: REQUIRES crossdomain.xml ON TOP LEVEL OF DOMAIN");			trace("If security error is still thrown, check for new policy file on twimg.com subdomain");			proxyURL = proxy;			loadPolicyFiles();		}			//--------------------------------------------------------------------------    //  Loading    //--------------------------------------------------------------------------				public function loadPolicyFiles():void		{			trace("TwitterSearchResultContainer.loadPolicyFiles a0-a5+s");			Security.loadPolicyFile("http://a0.twimg.com/crossdomain.xml");			Security.loadPolicyFile("http://a1.twimg.com/crossdomain.xml");			Security.loadPolicyFile("http://a2.twimg.com/crossdomain.xml");			Security.loadPolicyFile("http://a3.twimg.com/crossdomain.xml");			Security.loadPolicyFile("http://a4.twimg.com/crossdomain.xml");			Security.loadPolicyFile("http://a5.twimg.com/crossdomain.xml");			Security.loadPolicyFile("http://s.twimg.com/crossdomain.xml");		}				public function getFeedFromProxy(twitterURL:String):void 		{			trace("TwitterSearchResultContainer.getFeedFromProxy");			searchURL = proxyURL+"?url="+twitterURL;			var request:URLRequest = new URLRequest(searchURL);			request.method = URLRequestMethod.GET;			loader = new URLLoader();			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);			loader.addEventListener(Event.COMPLETE, XMLLoadComplete);			loader.load(request);		}				public function onIOError(event:IOErrorEvent):void 		{			trace("TwitterSearchResultContainer.onIOError");			var errorText:String = 'Oops. Looks like our search feed might be down right now. Please try your search at <a href="http://search.twitter.com" target="_blank">http://search.twitter.com</a>.';			dispatchEvent(new UIEvent(UIEvent.LOAD_COMPLETE));			displayError(errorText);		}				public function displayError(errorText:String):void 		{			errorText = "<body>"+errorText+"</body>";			var errorHTMLTextBlock:HTMLTextBlock = new HTMLTextBlock(errorText, 500, tweetStyleSheet);			addChild(errorHTMLTextBlock);			errorHTMLTextBlock.addEventListener(Event.COMPLETE, onBuildComplete);			this.visible = true;		}				public function XMLLoadComplete(event:Event):void 		{			trace("TwitterSearchResultContainer.XMLLoadComplete");			if (event.target.data!="") 			{				parseXML(XML(event.target.data));			}			else 			{				dispatchEvent(new UIEvent(UIEvent.LOAD_COMPLETE));				displayError('Oops. Looks like our search feed is down right now. You can try your search at <a href="http://search.twitter.com" target="_blank">search.twitter.com</a>.');			}		}			//--------------------------------------------------------------------------    //  Formatting    //--------------------------------------------------------------------------				public function parseXML(xml:XML):void 		{			trace("TwitterSearchResultContainer.parseXML");			var feedXML:XML = xml;			var currMinute:int;			var currHour:int;			var currDay:int;			var _tweetList:XMLList = feedXML.children();			for (var x:int = 0; x < _tweetList.length(); x++) 			{				if (_tweetList[x].name().localName == "entry") 				{					var thisTweet:XML = _tweetList[x];					var nodes:XMLList = thisTweet.children();					for (var y:int = 0; y < nodes.length(); y++) 					{						if (nodes[y].name().localName == "content") 						{							tweets.push(nodes[y].text());						} 						else if (nodes[y].name().localName == "link" && nodes[y].@type == "image/png") 						{							pics.push(nodes[y].@href);						} 						else if (nodes[y].name().localName == "author") 						{							var authorsXML:XMLList = nodes[y].children();							var i1:int = String(authorsXML[0]).indexOf("(")+1;							var i2:int = String(authorsXML[0]).indexOf(")");							var author:String = String(authorsXML[0]).substring(i1,i2);							authors.push(author);						} 						else if (nodes[y].name().localName == "updated") 						{							var timestamp:String = nodes[y].text();							var minute:int = int(timestamp.substring(14,16));							var hour:int = int(timestamp.substring(11,13));							var day:int = int(timestamp.substring(8,10));							var minutesAgo:int = 0;							if (hour==currHour) 							{								minutesAgo=currMinute-minute;							} 							else 							{								if (day==currDay)									minutesAgo = currMinute+(60-minute)+((currHour-hour-1)*60);								else 									minutesAgo = currMinute+(60-minute)+(((currHour+24)-hour-1)*60);							}							times.push(minutesAgo);						}					}				} 				else if (_tweetList[x].name().localName == "updated") 				{					var searchTimestamp:String = _tweetList[x].text();					currMinute = int(searchTimestamp.substring(14,16));					currHour = int(searchTimestamp.substring(11,13));					currDay = int(searchTimestamp.substring(8,10));				}			}			dispatchEvent(new UIEvent(UIEvent.LOAD_COMPLETE));			build();		}			//--------------------------------------------------------------------------    //  Building    //--------------------------------------------------------------------------				public function build():void 		{			trace("TwitterSearchResultContainer.build");			tweetsLoaded = 0;			addTweet();		}				public function addTweet():void 		{			var tweet:Sprite = new Sprite();			tweet.y = tweetsLoaded * 75;			addChild(tweet);						// add line			var line:Line = new Line(560, 1, 0x999999);			tweet.addChild(line);						// add tweet text			var tweetText:String = "<body>"+tweets[tweetsLoaded]+"</body>";			var newLine:RegExp = /\n/g;			tweetText = tweetText.replace(newLine, "");			var tweetTextBlock:HTMLTextBlock = new HTMLTextBlock(tweetText, 500, tweetStyleSheet);			tweetTextBlock.x = 56;			tweetTextBlock.y = 11;			tweet.addChild(tweetTextBlock);						// add tweet time stamp			var timeText:String;			if (times[tweetsLoaded] > 1) 				timeText = times[tweetsLoaded]+" minutes ago by "+authors[tweetsLoaded];			else				timeText = "Less than a minute ago by "+authors[tweetsLoaded];							var tweetTimestamp:HTMLTextBlock = new HTMLTextBlock(timeText, 500, tweetStyleSheet);			tweetTimestamp.x = 56;			tweetTimestamp.y = 48;			tweetTimestamp.alpha = .5;			tweet.addChild(tweetTimestamp);								// add profile pic			var picURL:String;			if (String(pics[tweetsLoaded]) == "undefined" || String(pics[tweetsLoaded]).indexOf(".bmp") != -1) 				picURL = TWITTER_BADGE_URL;			else				picURL = pics[tweetsLoaded];						var image:ImageDisplay = new ImageDisplay(picURL);			image.y = 11;			image.addEventListener(Event.COMPLETE, onTweetImageLoaded);			tweet.addChild(image);		}				public function onTweetImageLoaded(event:Event):void 		{			var image:ImageDisplay = ImageDisplay(event.target);			image.width = image.height = 48;						tweetsLoaded++;						if (tweetsLoaded < tweets.length)				addTweet();			else				onBuildComplete();		}				public function onBuildComplete(event:Event = null):void		{			trace("TwitterSearchResultContainer.onBuildComplete");			dispatchEvent(new Event(Event.COMPLETE));		}				public function clearTweets():void 		{			while (this.numChildren > 0) 			{				removeChild(this.getChildAt(0));			}			pics = [];			tweets = [];			times = [];			authors = [];		}	}}