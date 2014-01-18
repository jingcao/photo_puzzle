package  {
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	
	public class CameraUIStillImage extends MovieClip{
		
		private var deviceCameraApp:CameraUI = new CameraUI();
		private var imageLoader:Loader; 
		private var bitmapImage:Bitmap;
		
		public function CameraUIStillImage() {
			
			if( CameraUI.isSupported )
			{
				trace( "Initializing camera..." );
				
				deviceCameraApp.addEventListener( MediaEvent.COMPLETE, imageCaptured );
				deviceCameraApp.addEventListener( Event.CANCEL, captureCanceled );
				deviceCameraApp.addEventListener( ErrorEvent.ERROR, cameraError );
				
			}
			else
			{
				trace( "Camera interface is not supported.");
			}
		}
		
		public function launchCamera():void{
			deviceCameraApp.launch( MediaType.IMAGE );
		}
		
		public function getImage():Bitmap{
			return bitmapImage;
		}
		
		private function imageCaptured( event:MediaEvent ):void
		{
			trace( "Media captured..." );
			
			var imagePromise:MediaPromise = event.data;
			
			if( imagePromise.isAsync )
			{
				trace( "Asynchronous media promise." );
				imageLoader = new Loader();
				imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, asyncImageLoaded );
				imageLoader.addEventListener( IOErrorEvent.IO_ERROR, cameraError );
				
				imageLoader.loadFilePromise( imagePromise );
			}
			else
			{
				trace( "Synchronous media promise." );
				imageLoader.loadFilePromise( imagePromise );
				showMedia( imageLoader );
			}
		}
		
		private function captureCanceled( event:Event ):void
		{
			trace( "Media capture canceled." );
			//NativeApplication.nativeApplication.exit();
		}
		
		private function asyncImageLoaded( event:Event ):void
		{
			trace( "Media loaded in memory." );
			showMedia( imageLoader );
		}
		
		private function showMedia( loader:Loader ):void
		{
			this.bitmapImage=Bitmap(loader.content);
			this.dispatchEvent(new Event("onPictureTaken"));
		}
		
		private function cameraError( error:ErrorEvent ):void
		{
			trace( "Error:" + error.text );
		}
	}
}