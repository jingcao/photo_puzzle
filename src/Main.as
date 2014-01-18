package  {
	//import flash.display.Bitmap;
	//import flash.display.Graphics;
	
	//local imports
	import SlidePuzzle;
	import SwipeMenu;
	import common;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLRequest;
	
	import qnx.events.*;
	
	[SWF(width = "1024", height = "600", backgroundColor = "#FFFFFF", frameRate = "30")]  
	public class Main extends Sprite
	{
		private var slidePuzzle:SlidePuzzle;
		
		// swipe menu
		private var swipemenu:SwipeMenu;
		
		//Images
		private var splashImage:Loader;
		
		public function Main()
		{
			super();
			load();
			swipemenu = new SwipeMenu();
			addChild(swipemenu);
			swipemenu.addEventListener("onNewGame", onNewGame, false, 0, true)
		}
		
		private function onNewGame(e:Event):void{
			resetPuzzle();
		}
		
		private function resetPuzzle():void{
			
			var x:int;
			var y:int;
			//swipemenu.setPuzzleSize();
			x=swipemenu.getXsize();
			y=swipemenu.getYsize();
			
			if(slidePuzzle){ //puzzle currently exist then remove it and recreate a new one.
				slidePuzzle.clearPuzzle();
				removeChild(slidePuzzle);
			}
			
			slidePuzzle = new SlidePuzzle(x,y,this.swipemenu.getBitmapImage());
			addChild(slidePuzzle);
			this.swapChildren(swipemenu, slidePuzzle);
		}
		
		private function load():void{
			//Load splash image
			splashImage = new Loader();
			splashImage.contentLoaderInfo.addEventListener(Event.COMPLETE, showSplashPage);
			var request:URLRequest = new URLRequest("images/splash_screen.png");
			splashImage.load(request);
		}
		
		private function showSplashPage(e:Event):void{
			
			addChild(splashImage);
			this.swapChildren(this.swipemenu,this.splashImage);
			
		}
		
	}
	
}
