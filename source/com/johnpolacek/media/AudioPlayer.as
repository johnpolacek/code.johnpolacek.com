﻿package com.johnpolacek.media {		import flash.display.BlendMode;	import flash.display.Shape;	import flash.display.Sprite;	import flash.display.Loader;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.media.SoundLoaderContext;	import flash.net.URLRequest;	import flash.text.Font;	import flash.text.TextField;	import flash.text.TextFieldAutoSize;	import flash.text.TextFormat;	import flash.utils.Timer;	import com.johnpolacek.events.UIEvent;	import com.johnpolacek.media.SoundSpectrum;	import com.johnpolacek.shapes.RectangleShape;	import com.johnpolacek.ui.PlayPauseButton;	 /** * Player for a single mp3 file * * @example  * <br /> * Basic usage: * <code>import com.johnpolacek.media.AudioPlayer; * var player:AudioPlayer = new AudioPlayer(); * player.titleColor = 0xAAAAAA; * player.subtitleColor = 0x666666; * player.titleText = "Song Name"; * player.subtitleText = "Artist Name; * player.play("example.mp3");            // url of audio file * </code> * * @sends Event.COMPLETE # When load is complete. * @sends Event.SELECT # When load is complete. * @sends UIEvent.PLAYBACK_FINISH # When playback finishes. *  * @see com.johnpolacek.media.SoundSpectrum * @version  * <b>11 Apr 2010</b>  Displays % loaded during loading <br> * <b>30 Mar 2010</b>  Now uses TextFormat objects for TextFields <br> * <b>7 Mar 2010</b> * @author John Polacek, john@johnpolacek.com */	 		public class AudioPlayer extends Sprite {				/** Text that displays in player's title TextField. Default is "" */	  		public var titleText:String = "";		/** Text that displays in player's subtitle TextField. Default is "" */			public var subtitleText:String = "";		/** The TextFormat for the title TextField.  **/		public var titleTextFormat:TextFormat;		/** The TextFormat for the subtitle TextField.  **/		public var subtitleTextFormat:TextFormat;		/** The TextFormat for the note TextField.  **/		public var backgroundColor:uint = 0x000000;		/** Color of player buttons. Default is 0xFFFFFF */		public var buttonColor:uint = 0xFFFFFF;		/** Player track color. Default is 0x666666 */		public var trackColor:uint = 0x666666;		/** Width (in pixels) of player. Default is 400 */		public var playerWidth:Number = 400;		/** Height (in pixels) of player (not inluding progress bar). Default is 50 */		public var playerHeight:Number = 50;		/** Sound to be played by player. */		public var audio:Sound = null;		/** SoundChannel of player. */		public var soundChannel:SoundChannel = new SoundChannel();		/** Default is false. */		public var autoPlay:Boolean = false;				private var titleField:TextField;		private var subtitleField:TextField;		private var audioURL:String;		private var playControl:PlayPauseButton;		private var playerWindow:Sprite;		private var progressBar:Sprite;		private var progressTrack:Sprite;		private var windowShine:Sprite;		private var soundSpectrum:SoundSpectrum;		private var pausePosition:Number = 0;		private var isPlaying:Boolean;		private var loadTimer:Timer;		private var progressTimer:Timer;		private var duration:Number;				public function AudioPlayer()		{			titleTextFormat = new TextFormat(null,14,0xFFFFFF);			subtitleTextFormat = new TextFormat(null, 12, 0xAAAAAA);						// configure event listeners			//			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);		}			//--------------------------------------------------------------------------    //    //  CONTROLS    //    //--------------------------------------------------------------------------					/** Loads sound into player		* 		* @param url Audio file url (must be mp3)		* @param auto Sets autoPlay value		*/		public function load(url:String, auto:Boolean = false):void		{			var context:SoundLoaderContext = new SoundLoaderContext(1000, true);			autoPlay = auto;			audioURL = url;			audio = new Sound();			audio.load(new URLRequest(audioURL), context);			audio.addEventListener(IOErrorEvent.IO_ERROR, onIOError);			audio.addEventListener(Event.OPEN, onAudioOpen);			audio.addEventListener(Event.COMPLETE, onAudioLoadComplete);			buildPlayer();		}				/** Initiates audio playback  */		public function playAudio():void		{			if (!audio.bytesLoaded) 			{				trace("Must load audio first");			}			else			{				soundChannel = audio.play(pausePosition);				soundChannel.addEventListener(Event.SOUND_COMPLETE, onAudioFinish);				progressTrack.visible = true;				isPlaying = true;				progressTimer.start();				soundSpectrum.activate();				dispatchEvent(new Event(Event.SELECT));				updatePlayerDisplay();			}		}				/** Pauses audio playback  */		public function pauseAudio():void		{			pausePosition = soundChannel.position;			soundChannel.stop();			soundChannel.removeEventListener(Event.SOUND_COMPLETE, onAudioFinish);			isPlaying = false;			progressTimer.stop();			soundSpectrum.deactivate();			updatePlayerDisplay();		}				/** Updates player display  */		public function updatePlayerDisplay():void		{			if (playControl.getPlayState() != isPlaying) 				playControl.setPlayState(isPlaying);			windowShine.visible = !isPlaying;		}			//--------------------------------------------------------------------------    //    //  OBJECT CREATION    //    //--------------------------------------------------------------------------					private function buildPlayer():void		{						playerWindow = createPlayerWindow();			playControl = new PlayPauseButton(playerHeight, playerHeight, backgroundColor, buttonColor);			/*if (playerWindow.height > playControl.height) 				playControl.height = playControl.width = playerWindow.height;*/			progressBar = createProgressBar();			progressBar.y = playerHeight;			progressTimer = new Timer(50);			progressTimer.addEventListener(TimerEvent.TIMER, onProgress);			addChild(playerWindow);			addChild(playControl);			addChild(progressBar);			var playButtonShine:Sprite = new RectangleShape(playControl.width, playControl.height/2, 0xFFFFFF, .1);			addChild(playButtonShine);			windowShine = new RectangleShape(playerWidth - playControl.width - 1, playControl.height/2, 0xFFFFFF, .1);			windowShine.x = playControl.width + 1;			addChild(windowShine);			playControl.addEventListener(UIEvent.PLAY_CLICK, onPlayClick);			playControl.addEventListener(UIEvent.PAUSE_CLICK, onPauseClick);			progressBar.addEventListener(MouseEvent.CLICK, onProgressBarClick);			progressBar.buttonMode = true;						if (autoPlay) 				playAudio();			else 				pauseAudio();		}				private function createPlayerWindow():Sprite		{			var window:Sprite = new Sprite();			titleField = new TextField();			subtitleField = new TextField();			titleField.width = subtitleField.width = playerWidth - playerHeight;			titleField.blendMode = BlendMode.LAYER;			titleField.y = 5;			subtitleField.blendMode = BlendMode.LAYER;			subtitleField.y = playerHeight/2 + 2;			titleField.height = subtitleField.height = 1;			if (subtitleText == "")  				titleField.y = playerHeight/2 - Number(titleTextFormat.size)/3;			window.addChild(titleField);			window.addChild(subtitleField);			soundSpectrum = new SoundSpectrum(playerWidth - playerHeight - 1, playerHeight, backgroundColor, 1, buttonColor, .1);			soundSpectrum.x = playerHeight +1;						if (titleField) 				titleField.x = playerHeight + 10;						if (subtitleField) 				subtitleField.x = playerHeight + 10;						window.addChildAt(soundSpectrum, 0);			var bgr:Sprite = new RectangleShape(playerWidth, playerHeight, backgroundColor);			window.addChildAt(bgr, 0);			return window;		}				private function setText(tf:TextField, f:TextFormat, txt:String):void		{			tf.text = txt;			if (f.font != null) 				tf.embedFonts = true;			tf.setTextFormat(f);			tf.multiline = tf.wordWrap = true;			tf.autoSize = TextFieldAutoSize.LEFT;		}				private function createProgressBar():Sprite		{			var bar:Sprite = new Sprite();			var bgr:Sprite = new RectangleShape(playerWidth, 4, backgroundColor);			var bgrLighten:Sprite = new RectangleShape(playerWidth, 4, 0xFFFFFF, .2);			bgr.addChild(bgrLighten);			bar.addChild(bgr);			progressTrack = new RectangleShape(playerWidth, 4, trackColor);			bar.addChild(progressTrack);			progressTrack.visible = false;			return bar;		}			//--------------------------------------------------------------------------    //    //  EVENT HANDLERS    //    //--------------------------------------------------------------------------					private function onIOError(event:IOErrorEvent):void		{			trace(event.text);			dispatchEvent(event);		}				private function onRemoved(event:Event):void		{			soundChannel.stop();		}				private function onAudioOpen(event:Event):void		{			loadTimer = new Timer(50);			loadTimer.addEventListener(TimerEvent.TIMER, loadTimerHandler);			loadTimer.start();			dispatchEvent(new Event(Event.COMPLETE));		}				private function loadTimerHandler(event:TimerEvent):void		{			var percLoaded:int = int((audio.bytesLoaded / audio.bytesLoaded)*100);			setText(titleField, titleTextFormat, String(percLoaded+"% loaded"));		}				private function onAudioLoadComplete(event:Event):void		{			loadTimer.stop();			duration = audio.bytesTotal / (audio.bytesLoaded / audio.length);			if (titleText) 				setText(titleField, titleTextFormat, titleText);			if (subtitleText) 				setText(subtitleField, subtitleTextFormat, subtitleText);			if (autoPlay) 				playAudio();		}				private function onAudioFinish(event:Event):void		{			pauseAudio();			pausePosition = 0;			progressTrack.visible = false;			dispatchEvent(new UIEvent(UIEvent.PLAYBACK_FINISH));		}				private function onPlayClick(event:UIEvent):void		{			playAudio();		}				private function onPauseClick(event:UIEvent):void		{			pauseAudio();		}				private function onProgress(event:Event):void		{			var percentPlayed = soundChannel.position/duration;			progressTrack.width = progressBar.width * percentPlayed;		}				private function onProgressBarClick(event:MouseEvent):void		{			soundChannel.stop();			pausePosition = duration * ((event.localX * event.target.scaleX) / progressBar.width);			playAudio();		}	}}