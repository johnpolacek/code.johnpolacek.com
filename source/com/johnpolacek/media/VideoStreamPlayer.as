﻿package com.johnpolacek.media {		import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.display.Loader;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.AsyncErrorEvent;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.events.NetStatusEvent;    import flash.events.SecurityErrorEvent;	import flash.media.SoundTransform;    import flash.media.Video;    import flash.net.NetConnection;    import flash.net.NetStream;	import flash.net.URLRequest;	import flash.utils.Timer;	import com.johnpolacek.display.ImageDisplay;	import com.johnpolacek.events.UIEvent;	import com.johnpolacek.shapes.RectangleShape;	import com.johnpolacek.ui.ProgressBar;	import com.johnpolacek.ui.PlayPauseButton;	import com.johnpolacek.ui.VolumeControl;	import com.greensock.TweenLite;		/** * NetStream Video Player  * * @example  * <code>import com.johnpolacek.media.VideoStreamPlayer; * var player:AudioPlayer new VideoStreamPlayer(); * player.playVideo("example.flv"); * player.addController();   // adds default controls to player	 * player.addPoster("poster.jpg"); * player.autoRewind = true; * player.autoPlay = false; * addChild(player); * </code> * * * @see com.johnpolacek.ui.ProgressBar * @see com.johnpolacek.ui.PlayPauseButton * @see com.johnpolacek.ui.VolumeControl * * @sends Event.COMPLETE # When load is complete. * @sends UIEvent.PLAYBACK_START # When playback starts. * @sends UIEvent.PLAYBACK_FINISH # When playback finishes. *  * @version  * <b>20 Mar 2010</b> Now dispatches UIEvent.PLAYBACK_START <br> * <b>19 Mar 2010</b> Switched poster and controls objects to public vars. Enlarged controls. <br> * <b>7 Mar 2010</b> * @author John Polacek, john@johnpolacek.com */	 		public class VideoStreamPlayer extends Sprite {				/** Color of player buttons. Default is 0xFFFFFF */		public var buttonColor:uint = 0xFFFFFF;		/** Color of player background. Default is 0x000000 */		public var backgroundColor:uint = 0x000000;		/** Default is false. */		public var autoPlay:Boolean = false;		/** Default is true. */		public var autoRewind:Boolean = true;		/** Optional poster image that displays before video is played. */		public var poster:Sprite = new Sprite();		/** Video controls sprite. */		public var controls:Sprite = new Sprite();		/** Boolean determines if controller is inside or outside the video. Default is true. */		public var controlsOutside:Boolean = false;				private var connection:NetConnection;		private var stream:NetStream;		private var video:Video;		private var videoData:Object;		private var playerBackground:Sprite;		private var playControl:PlayPauseButton;		private var progressBar:ProgressBar;		private var volumeControl:VolumeControl;		private var controlsEnabled:Boolean = false;		private var isPlaying:Boolean = false;		private var progressTimer:Timer; // timer for updating progress bar during playback				/** Buffer time for the video in seconds. */// 		const BUFFER_TIME:Number = 8;		/** Default volume for player. */// 		const DEFAULT_VOLUME:Number	= 0.6;		/** Progress update delay in milliseconds. */// 		const PROGRESS_TIMER_DELAY:int = 50;						public function VideoStreamPlayer()		{			connection = new NetConnection();			connection.connect(null);			stream = new NetStream(connection);			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, aSyncErrorHandler);						var customClient:Object = new Object();			customClient.onMetaData = metaDataHandler;			stream.client = customClient;			stream.bufferTime = BUFFER_TIME;            video = new Video();            video.attachNetStream(stream);			video.smoothing = true;						// configure stage			//			this.visible = false;			addChild(video);			addChild(poster);			addChild(controls);						progressTimer = new Timer(PROGRESS_TIMER_DELAY, 0);			progressTimer.addEventListener(TimerEvent.TIMER, onProgressTimer);            			// configure event listeners			//			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);			poster.addEventListener(MouseEvent.CLICK, onPosterClick);			poster.addEventListener(MouseEvent.MOUSE_OVER, function():void { poster.alpha = 1; });			poster.addEventListener(MouseEvent.MOUSE_OUT, function():void { poster.alpha = .9; });		}			//--------------------------------------------------------------------------    //    //  CONTROLS    //    //--------------------------------------------------------------------------					/** Loads video from url.		*		* @param url Video url		* @param autoPlay Sets autoPlay boolean		*/		public function loadVideo(url:String, videoAutoPlay:Boolean = false):void		{			autoPlay = videoAutoPlay;			playVideo(url);			if (!autoPlay)				rewindVideo();			autoHideController();		}				/** Starts playback.		*		* @param url Video url (only used when no video is loaded)		*/		public function playVideo(url:String = null):void		{			if (!url) 			{				if (!videoData) 					trace("No video loaded.");				else 					resumeVideo();			}			else			{				stream.play(url);				isPlaying = true;								if (playControl)  					playControl.setPlayState(true);								if (progressBar)					progressTimer.start();			}						poster.visible = false;		}				/** Pauses playback. */		public function pauseVideo():void		{			stream.pause();			if (playControl)  				playControl.setPlayState(false);			progressTimer.stop();			isPlaying = false;		}				/** Resumes playback. */		public function resumeVideo():void		{			stream.resume();						if (playControl)  				playControl.setPlayState(true);						if (progressBar)  				progressTimer.start();						isPlaying = true;			poster.visible = false;		}				/** Returns and pauses playback to start of video. */		public function rewindVideo():void		{			stream.seek(0);			pauseVideo();			poster.visible = true;			if (progressBar)				progressBar.setProgress(0);		}				/** Sets playhead to a percentage of the video's duration.		*		* @param p Percentage of video duration		*/		public function seekVideo(p:Number):void		{			stream.seek(p);			poster.visible = false;		}			//--------------------------------------------------------------------------    //    //  OBJECT CREATION    //    //--------------------------------------------------------------------------					private function initPlayer():void		{			this.visible = true;			video.height = videoData.height;			video.width = videoData.width;			controls.y = videoData.height;			if (controlsEnabled) 				createControls();			if (!controlsOutside)				controls.y -= controls.height;			if (poster.numChildren > 0) 			{				poster.width = videoData.width;				poster.height = videoData.height;			}			dispatchEvent(new Event(Event.COMPLETE));		}				public function addPoster(filepath:String):void		{			var image:ImageDisplay = new ImageDisplay(filepath);			poster.addChild(image);			poster.buttonMode = true;			poster.alpha = .9;		}				public function addController():void		{			controlsEnabled = true;		}				private function createControls():void		{			var bgr:Sprite = new RectangleShape(videoData.width, 30, backgroundColor);			var shine:Sprite = new RectangleShape(videoData.width, 15, buttonColor, .1);						playControl = new PlayPauseButton(30, 30, backgroundColor, buttonColor);						volumeControl = new VolumeControl(60, 30, backgroundColor, buttonColor);			volumeControl.x = video.width - volumeControl.width;						progressBar = new ProgressBar(video.width - playControl.width - volumeControl.width - 30, 15, backgroundColor, buttonColor);			progressBar.x = playControl.width + 15;			progressBar.y = (bgr.height - progressBar.height) / 2;						controls.addChild(bgr);			controls.addChild(playControl);			controls.addChild(progressBar);			controls.addChild(volumeControl);			controls.addChild(shine);						progressBar.addEventListener(UIEvent.PROGRESS_UPDATE, onProgressBarUpdate);			playControl.addEventListener(UIEvent.PLAY_CLICK, onPlayClick);			playControl.addEventListener(UIEvent.PAUSE_CLICK, onPauseClick);			volumeControl.addEventListener(UIEvent.VOLUME_ADJUST, onVolumeAdjust);			volumeControl.setVolume(DEFAULT_VOLUME);			if (isPlaying) 				progressTimer.start();			playControl.setPlayState(isPlaying);		}				/** Moves controller inside the video player and hides on MOUSE_OUT **/		public function autoHideController():void		{			controlsOutside = false;			controls.y = video.height - controls.height;			addEventListener(MouseEvent.MOUSE_OVER, showControls);			addEventListener(MouseEvent.MOUSE_OUT, hideControls);			if (autoPlay)				controls.alpha = 0;		}			//--------------------------------------------------------------------------    //    //  EVENTS HANDLERS    //    //--------------------------------------------------------------------------				private function netStatusHandler(event:NetStatusEvent):void 		{			if (event.info.code.toString() == "NetStream.Play.Start" && autoPlay) 				dispatchEvent(new UIEvent(UIEvent.PLAYBACK_START));			if (event.info.code.toString() == "NetStream.Play.Stop")  				onVideoFinish();			if (event.info.code.toString() == "NetStream.Play.StreamNotFound")  				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "Video Stream not found"));        }        private function securityErrorHandler(event:SecurityErrorEvent):void 		{            trace("VideoStreamPlayer securityErrorHandler: " + event);        }        private function metaDataHandler(data:Object):void 		{           if (data)			{				videoData = data;				initPlayer();			}        }				private function aSyncErrorHandler(event:AsyncErrorEvent):void		{			trace(event.text);		}				private function onRemoved(event:Event):void		{			stream.pause();		}				private function onVideoFinish():void		{			trace("VideoStreamPlay.onVideoFinish");			if (autoRewind)				rewindVideo();			dispatchEvent(new UIEvent(UIEvent.PLAYBACK_FINISH));		}				private function onPlayClick(event:UIEvent):void		{			trace("VideoStreamPlay.onPlayClick");			dispatchEvent(new UIEvent(UIEvent.PLAYBACK_START));			resumeVideo();		}				private function onPauseClick(event:UIEvent):void		{			pauseVideo();		}				private function onPosterClick(event:MouseEvent):void		{			if(videoData) 				playVideo();		}				private function showControls(event:MouseEvent):void		{			TweenLite.to(controls, .25, {alpha:1});		}				private function hideControls(event:MouseEvent):void		{			TweenLite.to(controls, .25, {alpha:0});		}				private function onProgressBarUpdate(event:UIEvent):void		{			seekVideo(event.value * videoData.duration);		}		private function onProgressTimer(event:TimerEvent):void		{			if (videoData)  			{				var p:Number = stream.time / videoData.duration;				progressBar.setProgress(stream.time / videoData.duration);			}		}				private function onVolumeAdjust(event:UIEvent):void		{			var transform:SoundTransform = stream.soundTransform;			transform.volume = event.value;			stream.soundTransform = transform;		}	}}