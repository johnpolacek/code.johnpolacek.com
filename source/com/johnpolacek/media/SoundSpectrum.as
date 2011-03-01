﻿package com.johnpolacek.media {		import flash.display.Graphics;	import flash.display.Sprite;	import flash.media.SoundMixer;	import flash.events.Event;	import flash.events.TimerEvent;	import flash.utils.ByteArray;	import flash.utils.Timer;	import flash.system.Security;	import com.johnpolacek.shapes.RectangleShape;	/** * Sound spectrum visualizer animated within a rectangle container. * * @example  * <code>import com.johnpolacek.media.SoundSpectrum; * var soundSpectrum = new SoundSpectrum(400, 100, 0x333333, 1, 0x999999, .1); * addChild(soundSpectrum); * soundSpectrum.activate(); * </code> * * @version 7 Mar 2010 * @author John Polacek, john@johnpolacek.com */		public class SoundSpectrum extends Sprite {				/** Background color of rectangle container shape */			public var backgroundColor:uint;		/** Background alpha of rectangle container shape */		public var backgroundAlpha:Number;		/** Fill color of spectrum */		public var fillColor:uint;		/** Fill alpha of spectrum */		public var fillAlpha:Number;		/** Height of the spectrum container rectangle*/		public var spectrumHeight:Number;		/** Width of the spectrum container rectangle*/		public var spectrumWidth:Number;								private var spectrumContainer:Sprite = new Sprite();		private var spectrumGraphics:Graphics;		private var spectrumTimer:Timer;				private static const CHANNEL_LENGTH:int = 256;				/** 		* @param w Sets spectrumWidth		* @param h Sets spectrumHeight		* @param bc Sets backgroundColor, default is 0x999999		* @param ba Sets backgroundAlpha, default is 1		* @param fc Sets fillColor, default is 0x666666		* @param fa Sets fillAlpha, default is 1		*/		public function SoundSpectrum(w:Number, h:Number, bc:uint=0x999999, ba:Number = 1, fc:uint=0x666666, fa:Number = 1) 		{			backgroundColor = bc;			backgroundAlpha = ba;			fillColor = fc;			fillAlpha = fa;			spectrumHeight = h;			spectrumWidth = w;			spectrumTimer = new Timer(50);            spectrumTimer.addEventListener(TimerEvent.TIMER, updateSpectrum);			var bgr:Sprite = new RectangleShape(spectrumWidth, spectrumHeight, backgroundColor, backgroundAlpha);			addChild(bgr);			spectrumContainer = new Sprite();			addChild(spectrumContainer);			spectrumGraphics = spectrumContainer.graphics;			spectrumContainer.scaleX = spectrumWidth/((CHANNEL_LENGTH-1)*2);			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);		}				/** Starts animation */			public function activate():void		{			spectrumTimer.start();		}				/** Ends animation */			public function deactivate():void		{			spectrumTimer.stop();			spectrumGraphics.clear();		}				private function updateSpectrum(event:TimerEvent = null):void		{			var bytes:ByteArray = new ByteArray();			Security.allowDomain('*');            try 			{				SoundMixer.computeSpectrum(bytes, false, 0);			}			catch (error:SecurityError)			{				// catches flash player bug http://bugs.adobe.com/jira/browse/FP-147			}						if (bytes.length > 0) 				drawSpectrum(bytes);			else 				drawRandom();		}				private function drawSpectrum(bytes:ByteArray):void		{			// begin drawing spectrum			//			spectrumGraphics.clear();			spectrumGraphics.beginFill(fillColor, fillAlpha);            spectrumGraphics.moveTo(0, 0);			            // get left channel values			var leftValues:Array = [];			for (var i:int = 0; i < CHANNEL_LENGTH; i++) 			{				leftValues.push(bytes.readFloat() * spectrumHeight/2);			}						// get right channel values			var rightValues:Array = [];			for (i = CHANNEL_LENGTH; i > 0; i--) 			{                rightValues.push(bytes.readFloat() * spectrumHeight);            }						// get average of left/right channels to draw spectrum			var n:Number;            for (i = 0; i < CHANNEL_LENGTH; i++) 			{                n = (leftValues[i] + rightValues[i]) / 2;                spectrumGraphics.lineTo(i * 2, spectrumHeight/2 - n);            }						// finish drawing spectrum			//			spectrumGraphics.lineTo((CHANNEL_LENGTH * 2) - 2, 0);            spectrumGraphics.endFill();		}				private function drawRandom():void		{			// begin drawing spectrum			//			spectrumGraphics.clear();			spectrumGraphics.beginFill(fillColor, fillAlpha);            spectrumGraphics.moveTo(0, 0);			            for (var i:int = 0; i < CHANNEL_LENGTH; i++) 			{				spectrumGraphics.lineTo(i * 2, (Math.random() * spectrumHeight/2) + spectrumHeight/4);            }						// finish drawing spectrum			//			spectrumGraphics.lineTo((CHANNEL_LENGTH * 2) - 2, 0);            spectrumGraphics.endFill();		}				private function onRemovedFromStage(event:Event):void		{			deactivate();		}			}}