﻿package com.johnpolacek.widgets {	import flash.display.MovieClip;	import flash.display.SimpleButton;	import flash.display.Shape;	import com.greensock.TweenLite;	import com.greensock.easing.Expo;	import com.johnpolacek.events.TrackEvent;		public class RolloverGridSquare extends MovieClip {				private var picStartX:Number;		private var picStartY:Number;		private var maskStartX:Number;		private var maskStartY:Number;		private var picStartW:Number;		private var picStartH:Number;		private var picOverX:Number;		private var picOverY:Number;		private var picOverW:Number;		private var picOverH:Number;				private var outline:Shape = new Shape();		public var hitzone:MovieClip = new MovieClip();				public function RolloverGridSquare() 		{			picOver_mc.visible=false;			picStartX=pic_mc.x;			picStartY=pic_mc.y;			maskStartX=picMask_mc.x;			maskStartY=picMask_mc.y;			picStartW=picMask_mc.width;			picStartH=picMask_mc.height;			picOverX=picOver_mc.x;			picOverY=picOver_mc.y;			picOverW=picOver_mc.width;			picOverH=picOver_mc.height;			removeChild(picOver_mc);						outline.graphics.beginFill(0x000000,0);			outline.graphics.lineStyle(1, 0xFFFFFF,1,false,"none");            outline.graphics.drawRect(0,0,picStartW-1,picStartH-1);			outline.graphics.endFill();			outline.x=maskStartX+.5;			outline.y=maskStartY+.5;			addChild(outline);						var hitbox:Shape = new Shape();			hitbox.graphics.beginFill(0x000000,0);			hitbox.graphics.drawRect(0,0,picStartW-1,picStartH-1);			hitbox.graphics.endFill();			hitbox.x=maskStartX+.5;			hitbox.y=maskStartY+.5;			hitzone.addChild(hitbox);			addChild(hitzone);						txt_mc.alpha=0;		}		public function tweenOn():void 		{			TweenLite.to(picMask_mc, .5, {x:picOverX, y:picOverY, width:picOverW, height:picOverH, ease:Expo.easeInOut});			TweenLite.to(pic_mc, .5, {x:picOverX, y:picOverY,ease:Expo.easeInOut});			TweenLite.to(outline, .5, {x:picOverX+.5, y:picOverY+1, width:picOverW+2, height:picOverH+2, ease:Expo.easeInOut});			TweenLite.to(txt_mc, .25, {alpha:1,delay:.3,onComplete:onRolloverComplete});		}		private function onRolloverComplete():void 		{			dispatchEvent(new TrackEvent(TrackEvent.TRACK,"TeamRollover ",this.name));		}		public function tweenOff():void 		{			TweenLite.to(txt_mc, .1, {alpha:0});			TweenLite.to(picMask_mc, .5, {x:maskStartX, y:maskStartY, width:picStartW, height:picStartH, ease:Expo.easeInOut});			TweenLite.to(pic_mc, .5, {x:picStartX, y:picStartY,ease:Expo.easeInOut});			TweenLite.to(outline, .5, {x:maskStartX+.5, y:maskStartY+.5, width:picStartW-1, height:picStartH-1, ease:Expo.easeInOut});		}	}}