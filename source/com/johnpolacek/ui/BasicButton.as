﻿package com.johnpolacek.ui {		import flash.display.BlendMode;	import flash.display.Sprite;	import flash.events.MouseEvent;	/** * The BasicButton class is used to create basic buttons that  * contain a buttonValue property that can be used to store a string value. * * For example, use BasicButton objects for creating a menu and on * click events use the buttonValue property to load new sections. * Or assign a filename to the buttonValue property to initiate lightbox content. *  * By default, BasicButtons have MOUSE_OUT and MOUSE_OVER events * which toggle the transparency between .8(out) and 1(over) which * is deactivated if the select(true); method is called. * * @example  * <code>import com.johnpolacek.ui.BasicButton; * import com.johnpolacek.shapes.RectangleShape; * * var exampleButton:BasicButton = new BasicButton("A string stored by the button"); * var buttonShape:Sprite = new RectangleShape(50); * exampleButton.addChild(buttonShape); * </code> *  * @author John Polacek, john@johnpolacek.com */	 	public class BasicButton extends Sprite 	{		public var buttonValue:String;		public var baseAlpha:Number = .9;		public var rolloverAlpha:Number = 1;		private var isSelected:Boolean = false;		public function BasicButton(val:String = "", 									enableSimpleRollovers:Boolean = true, 									ba:Number = .9, 									ra:Number = 1) 		{			buttonValue = val;			this.buttonMode = true;			this.blendMode = BlendMode.LAYER;			if (enableSimpleRollovers) 				addSimpleRollovers(ba, ra);		}				public function addSimpleRollovers(ba:Number = .9, ra:Number = 1):void		{			baseAlpha = ba;			rolloverAlpha = ra;			this.alpha = baseAlpha;			addEventListener(MouseEvent.MOUSE_OVER,onOver);			addEventListener(MouseEvent.MOUSE_OUT,onOut);		}				private function onOver(event:MouseEvent):void		{			this.alpha = rolloverAlpha;		}				private function onOut(event:MouseEvent):void		{			if (!isSelected)				this.alpha = baseAlpha;		}				public function select(sel:Boolean = true):void		{			isSelected = sel;			if (isSelected) 				this.alpha = rolloverAlpha;			else				this.alpha = baseAlpha;						}	}}