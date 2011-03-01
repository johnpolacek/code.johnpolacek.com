﻿package com.johnpolacek.ui {		import flash.display.Sprite;	import flash.events.MouseEvent;	import com.greensock.TweenLite;	import com.greensock.plugins.*;	import com.johnpolacek.events.UIEvent;	import com.johnpolacek.ui.BasicButton;	import com.johnpolacek.ui.BasicButtonMenu;	/** * The DropDownButtonMenu extends BasicButtonMenu to allow for the creation of dropdown menu navigation *  * @version  * <b>11 May 2010</b> * @author John Polacek, john@johnpolacek.com */	 	public class DropDownButtonMenu extends BasicButtonMenu 	{				/** @param ba Alpha of button when not selected. Default .9*/		public function DropDownButtonMenu(ba:Number = .9) 		{			buttonAlpha = ba;			isVertical = true;			TweenPlugin.activate([AutoAlphaPlugin]);		}				public function addDropDownMenu(menu:BasicButtonMenu, buttonIndex:int):void		{			var button:BasicButton = buttons[buttonIndex];			button.addEventListener(MouseEvent.MOUSE_OVER, showDropDown);			button.addEventListener(MouseEvent.MOUSE_OUT, hideDropDown);			menu.bubbles = false;			menu.showButtonSelection = false;			menu.addEventListener(UIEvent.BUTTON_SELECT, onDropDownSelect);			menu.y = button.height;			button.addChild(menu);			menu.visible = false;		}				public function showDropDown(event:MouseEvent):void		{			var button:BasicButton = BasicButton(event.currentTarget);			var menu:BasicButtonMenu = BasicButtonMenu(button.getChildAt(1));			TweenLite.to(menu, .5, {autoAlpha:1});		}				public function hideDropDown(event:MouseEvent):void		{			var button:BasicButton = BasicButton(event.currentTarget);			var menu:BasicButtonMenu = BasicButtonMenu(button.getChildAt(1));			TweenLite.to(menu, .5, {autoAlpha:0});		}				/** DropDown menu button select handler */		public function onDropDownSelect(event:UIEvent):void		{			selectButton(buttons.indexOf(event.target.parent));			dispatchEvent(new UIEvent(UIEvent.DROPDOWN_SELECT, event.value));		}	}}