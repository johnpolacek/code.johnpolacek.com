﻿package com.johnpolacek.ui {	import flash.display.Sprite;	import com.greensock.TweenLite;	import com.greensock.easing.Expo;	import com.johnpolacek.events.UIEvent;	import com.johnpolacek.shapes.RectangleShape;	import com.johnpolacek.ui.Scrollbar;	/** * Simple scrollbar class for full screen flash apps * * @example  * <br /> * <code> * // create scrollbox for container sprite masked to 400 pixels high,  * // with a scrubber 40 pixels high with a color of 0x0099999 and a  * // track color of 0x003333 (100% opacity) with a width of 10 pixels * var scrollbox:Scrollbox = new Scrollbox(400, 0x009999, 1, 0x003333, 1, 10, 40); * scrollbox.setContent(container); * addChild(scrollbox); * </code>  *  * @see com.johnpolacek.events.UIEvent * @version 14 Apr 2010 * @author John Polacek, john@johnpolacek.com */	 	public class Scrollbox extends Sprite {		public var scrollbar:Scrollbar;				private var boxHeight:int;				private var scrollContent:Sprite = new Sprite();		private var scrollMask:Sprite = new Sprite();		/**  		* @param h Sets height of the box		* @param sc Sets color of scrubber. Default is 0xFFFFFF		* @param sa Sets alpha of scrubber. Default is .5		* @param tc Sets color of track. Default is 0x000000		* @param ta Sets alpha of track. Default is .25		* @param tc Sets thickness of track. Default is 16 pixels		* @param sh Sets height of scrubber. Default is 80 pixels		**/		public function Scrollbox(h:int,								  sc:uint = 0xFFFFFF,								  sa:Number = .5,								  tc:uint = 0x000000,								  ta:Number = .25,								  t:int = 16,								  sh:int = 80) 		{			this.visible = false;			boxHeight = h;			scrollbar = new Scrollbar(boxHeight, sc, sa, tc, ta, t, sh);			addChild(scrollContent);			addChild(scrollMask);			scrollContent.mask = scrollMask;			addChild(scrollbar);			scrollbar.addEventListener(UIEvent.SCROLLBAR_MOVE, onScroll);		}				/**  		* Sets the content		* 		**/		public function setContent(c:Sprite):void		{			this.visible = true;			if (scrollContent.numChildren != 0)			{				scrollContent.removeChildAt(0);				scrollMask.removeChildAt(0);			}			scrollContent.addChild(c);			scrollbar.x = scrollContent.width + 1;			scrollMask.addChild(new RectangleShape(scrollContent.width, boxHeight));			scrollbar.clickPercent = (scrollContent.height / scrollMask.height) * .5;			scrollbar.visible = (scrollMask.height < scrollContent.height);		}				/** Scrolls content **/		public function onScroll(event:UIEvent):void		{			var maxScroll:Number = scrollContent.height - scrollMask.height;			var newY:Number = -(maxScroll * scrollbar.percent);			TweenLite.to(scrollContent, .5, {y:newY, ease:Expo.easeOut});		}	}}