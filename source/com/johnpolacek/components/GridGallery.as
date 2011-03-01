﻿package com.johnpolacek.components {		import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import com.johnpolacek.components.ButtonGrid;	import com.johnpolacek.components.Lightbox;	import com.johnpolacek.components.LightboxFormat;	import com.johnpolacek.ui.BasicButton;	import com.johnpolacek.events.UIEvent;	/** * Loads an array of thumbnails and arranges them in a grid. * Clicking on a thumbnail launches content from a corresponding * array in a lightbox window. *  * @example  * <br /> * Create grid gallery 8 images wide x 3 images high with 1 pixel spacing, then * use build method to create - 1st param is array of thumbs, 2nd is array of content * <code> * var gallery:GridGallery = new GridGallery(8, 3, 1);  * gallery.build(["thumb1.jpg","thumb2.jpg"...], ["image.jpg","video.flv"...]);   * </code>  *  * @see com.johnpolacek.components.Lightbox * @see com.johnpolacek.components.ButtonGrid * @version 7 Mar 2010 * @author John Polacek, john@johnpolacek.com */		public class GridGallery extends Sprite {				/** Alpha of thumbnail **/		public var baseAlpha:Number = .8;		/** Rollover alpha of thumbnail **/		public var rolloverAlpha:Number = 1;		/** If true, grid is centered to the size of the stage. Default false. **/		public var centerGrid:Boolean = false;		/** X position of grid. Default is 0. **/		public var gridX:int = 0;		/** Y position of grid. Default is 0. **/		public var gridY:int = 0;		/** LightboxFormat object **/		public var lightboxFormat:LightboxFormat = new LightboxFormat();		/** If true, gallery sizes dynamically to stage size. Default is false. **/				private var grid:ButtonGrid;		private var lightbox:Lightbox;				/** 		* @param w Sets grid width (number of images wide)		* @param h Sets grid height (number of images tall)		* @param s Sets grid spacing between sprites in pixels (default is 0)		*/			public function GridGallery(w:int, h:int = 0, s:int = 0) 		{			grid = new ButtonGrid(w,h,s);			grid.transitionDuration = .5;			addChild(grid);		}				/** Builds the grid and lightbox. Thumbnail button array corresponds to the content array.		* thumbnails[5] opens content[5]	 	* 		* @param thumbnails An array of image url's that will become the thumbnail buttons		* @param content Content array that corresponds to the thumbnail buttons.		*/		public function build(thumbnails:Array, content:Array):void		{			lightbox = new Lightbox(lightboxFormat);			addChild(lightbox);						lightbox.createContentGroupFromArray(content);						grid.x = gridX;			grid.y = gridY;			if (centerGrid)			{				grid.alignCenter = centerGrid;				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			}			grid.loadImages(thumbnails);			grid.addEventListener(Event.COMPLETE, onGridLoadComplete);			grid.addEventListener(UIEvent.BUTTON_SELECT, onButtonSelect);		}				public function setSize(w:int, h:int):void		{			lightboxFormat.lightboxWidth = w;			lightboxFormat.lightboxHeight = h;		}				private function onAddedToStage(event:Event):void		{			if (centerGrid)			{				center();				stage.addEventListener(Event.RESIZE, center);			}		}				private function center(event:Event = null):void		{			grid.x = stage.stageWidth/2;			grid.y = stage.stageHeight/2;		}				/** Image load complete handler */			public function onGridLoadComplete(event:Event):void		{			trace("GridGallery.onGridLoadComplete");		}				public function onButtonSelect(event:UIEvent):void		{			lightbox.displayContentIndex(event.value);		}	}}