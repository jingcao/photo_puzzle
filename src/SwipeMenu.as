package
{
	
	
	import CameraUIStillImage;
	
	import caurina.transitions.Tweener;
	
	import flash.display.*;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.*;
	
	import qnx.events.*;
	import qnx.system.*;
	import qnx.ui.buttons.*;

	public class SwipeMenu extends Sprite
	{
		// CameraApp OBJ
		private var camera:CameraUIStillImage = new CameraUIStillImage();
		
		// Sprites
		private var menu:Sprite = null;
		private var thumbPuzzleImage:Sprite = new Sprite(); 
		private var previewPuzzleImage:Sprite;
		
		// Loaders
		private var puzzleImage:Loader = new Loader();
		
		// Puzzle Image
		private var bitmapPuzzleImage:Bitmap = null;
		private var currentPuzzleImage:Bitmap = null;
		//private var thumbPuzzleImage:Bitmap = null;
		
		// buttons
		private var resetButton:qnx.ui.buttons.LabelButton;
		private var randomPicButton:qnx.ui.buttons.LabelButton;
		private var previousButton:qnx.ui.buttons.LabelButton;
		private var nextButton:qnx.ui.buttons.LabelButton;
		private var hideMenuButton:qnx.ui.buttons.LabelButton;
	
		// boolean
		private static var previewShown:Boolean = false;
		private static var menuShown:Boolean = false;
		
		// radio buttons
		private var rb1:RadioButton;
		private var rb2:RadioButton;
		private var rb3:RadioButton;
		private var rb4:RadioButton;
		private var rbg1:RadioButtonGroup;
		private static var xSize:int=4;
		private static var ySize:int=3;
		private var cameraButton:IconButton = new IconButton();

		// constants
		private const thumbImageWidth:int = 154; 
		private const thumbImageHeight:int = 90; 
		private const CORNER_RADIUS:int = 50;
		private const MENU_HEIGHT:int = 100+CORNER_RADIUS;
		private const MAX_IMAGE_INDEX:int = 39;
		
		
		// int
		private var imageIndex:int=1; //default is 1
		
		public function SwipeMenu()
		{
			super();
			QNXApplication.qnxApplication.addEventListener(QNXApplicationEvent.SWIPE_DOWN, onSwipeDown);
			
		}
		
		// event handler of user swiping down to open menu
		private function onSwipeDown(e:Event):void {

			if (!menu) { //initialize menu if it has not been initialized
				initMenu();
				addChild(menu);
			}
			showMenu();
		}
		
		private function initMenu():void{
			
			menu = new Sprite();
			
			// init camera event listener
			camera.addEventListener("onPictureTaken", onPictureTaken, false, 0, true); // camera object generates onPictureTaken events so capure it.
			
			menu.graphics.beginFill(0x949494);
			menu.graphics.drawRoundRect(0, 0, common.DEVICE_X_RESOLUTION, MENU_HEIGHT, CORNER_RADIUS, CORNER_RADIUS );

			// include the next two lines to animate the menu opening
			menu.y = -(MENU_HEIGHT+CORNER_RADIUS); //set the position of the menu off the screen and tween it into view.
			menu.alpha = 0.75 ;
			
			// add new game button
			resetButton = new LabelButton();
			resetButton.setPosition(30,80);
			resetButton.label="New Game";
			resetButton.width=resetButton.label_txt.width-30; 
			resetButton.addEventListener(MouseEvent.CLICK, newGameClicked);
			menu.addChild(resetButton);
			
			// add hid menu button
			hideMenuButton = new LabelButton();
			hideMenuButton.label="^";
			hideMenuButton.width=hideMenuButton.label_txt.width-110; 
			hideMenuButton.setPosition(common.DEVICE_X_RESOLUTION-30-hideMenuButton.width,80);
			hideMenuButton.addEventListener(MouseEvent.CLICK, hideMenuClicked);
			menu.addChild(hideMenuButton);
			
			// add radio buttons
			var rb_width:int = 90;
			
			rb1 = new RadioButton();
			rb1.setPosition(200, 60)
			rb1.label = "4x3";
			rb1.width=rb_width;
			rb1.groupname = "rbg1_puzzle_size";
			menu.addChild( rb1 );
			
			rb2 = new RadioButton();
			rb2.setPosition(rb1.x, rb1.y + 40);
			rb2.label = "5x4";
			rb2.width=rb_width;
			rb2.groupname = "rbg1_puzzle_size";
			menu.addChild( rb2 );
			
			rb3 = new RadioButton();
			rb3.setPosition(rb1.x+rb1.width+30, rb1.y);
			rb3.label = "6x5";
			rb3.width=rb_width;
			rb3.groupname = "rbg1_puzzle_size";
			menu.addChild( rb3 );
			
			rb4 = new RadioButton();
			rb4.setPosition(rb3.x, rb2.y);
			rb4.label = "9x7";
			rb4.width=rb_width;
			rb4.groupname = "rbg1_puzzle_size";
			menu.addChild( rb4 );
			
			rbg1 = RadioButtonGroup.getGroup("rbg1_puzzle_size");
			rbg1.addButton(rb1);
			rbg1.addButton(rb2);
			rbg1.addButton(rb3);
			rbg1.addButton(rb4);
			rbg1.addEventListener(MouseEvent.CLICK, rbg1Change);
			rbg1.setSelectedRadioButton(rb2);
			
			thumbPuzzleImage.x = rb3.x+rb3.width+30;
			thumbPuzzleImage.y = rb3.y-5;
			
			// add random picture button
			randomPicButton = new LabelButton();
			randomPicButton.setPosition(thumbPuzzleImage.x+thumbImageWidth+30,rb3.y);
			randomPicButton.label="Random Pic";
			randomPicButton.width=randomPicButton.label_txt.width-30; 
			randomPicButton.addEventListener(MouseEvent.CLICK, onloadRandomImage);
			menu.addChild(randomPicButton);
			loadBitmapFromFile(this.getImagePath());
			
			// add previous image button
			previousButton = new LabelButton();
			previousButton.setPosition(randomPicButton.x, randomPicButton.y+randomPicButton.height-2);
			previousButton.label="<<";
			previousButton.width=randomPicButton.width/2;
			previousButton.addEventListener(MouseEvent.CLICK, onLoadPreviousImage);
			menu.addChild(previousButton);
			
			// add next image button
			nextButton = new LabelButton();
			nextButton.setPosition(previousButton.x+previousButton.width, previousButton.y);
			nextButton.label=">>";
			nextButton.width=randomPicButton.width/2;
			nextButton.addEventListener(MouseEvent.CLICK, onLoadNextImage);
			menu.addChild(nextButton);
			
			//cameraButton.size = 100;
			cameraButton.setPosition(randomPicButton.x+randomPicButton.width+30, randomPicButton.y+1);
			cameraButton.setSize(112,84);
			cameraButton.setIcon("images/camera_icon.png");
			cameraButton.addEventListener(MouseEvent.CLICK, onLoadFromCamera);
			menu.addChild(cameraButton);
			
		}
		
		private function onLoadFromCamera(e:Event):void{
			//this.addChild(this.camera);
			camera.launchCamera();
		}
		
		private function onPictureTaken(e:Event):void{
			clearThumbAndPreview();
			// create new image to hold loaded bitmap
			bitmapPuzzleImage = camera.getImage();
			bitmapPuzzleImage = cropImage(bitmapPuzzleImage);	
			initPreviewThumb(bitmapPuzzleImage);
			this.showPuzzlePreview();
		}
		
		// create the Loader Object from external source
		private function loadBitmapFromFile(bitmapFilePath:String):void {
			puzzleImage.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loadingDone);
			var request:URLRequest = new URLRequest(bitmapFilePath);
			puzzleImage.load(request);
		}
		
		// bitmap done loading make a bitmap image.
		private function loadingDone(event:Event):void {

			// create new image to hold loaded bitmap
			bitmapPuzzleImage = Bitmap(event.target.loader.content);
			bitmapPuzzleImage = cropImage(bitmapPuzzleImage);	
			
			initPreviewThumb(bitmapPuzzleImage);
		}
		
		private function initPreviewThumb(bitmapImage:Bitmap):void{
			// thumb image init
			thumbPuzzleImage.addChild(common.scaleBitmap(bitmapImage, thumbImageWidth, thumbImageHeight));
			thumbPuzzleImage.addEventListener(MouseEvent.CLICK, togglePuzzlePreview); // add mouse click listener to display larger preview			
			menu.addChild(thumbPuzzleImage);
			
			// preview image init
			previewPuzzleImage = common.getImageWithBoarder(
				common.scaleBitmap(bitmapImage, bitmapImage.width*0.75, bitmapImage.height*0.75), 3, 0xFFFFFF);
			//set previewPuzzleImage Location (hidden to begin with)
			previewPuzzleImage.x = common.DEVICE_X_RESOLUTION +10;
			previewPuzzleImage.y = (common.DEVICE_Y_RESOLUTION-previewPuzzleImage.height)/2 + 50;
			addChild(previewPuzzleImage);
		}
		/* If image is larger than the standard size of 1024x600 then crop it to that size. 
		TODO: - imeplement new image cropping algorithm -> First shrike image to the smallest dimension of 1024h or 600w and then crop down the middle. 
			  reject pictures that have width < 600 and height <1024 
			  - add error checking for wrong image
		
			@param image: the image to be cropped
			@return croppedImage:Bitmap new image that is cropped
		*/
		public function cropImage(image:Bitmap):Bitmap {		
			var croppedImage:Bitmap =  new Bitmap(new BitmapData(common.DEVICE_X_RESOLUTION,common.DEVICE_Y_RESOLUTION));
			var tempImage:Bitmap=image;
			var shrinkHeight:int;
			var shrinkWidth:int;
			
			var width_ratio:Number=common.DEVICE_X_RESOLUTION/tempImage.width; //larger the ratio means closer x is to the image width.
			var height_ratio:Number=common.DEVICE_Y_RESOLUTION/tempImage.height;
			// TODO: future test for invalid picture size.

			
			//images width or height larger than the device resolution then crop image
			if (tempImage.width>common.DEVICE_X_RESOLUTION || tempImage.height>common.DEVICE_Y_RESOLUTION){
				//shriking image
				if (height_ratio!=1 && width_ratio!=1){ // if width or height is equal to device resolution width/height then don't resize just crop
					if (height_ratio < width_ratio){ // width is limiting (closer to resolution width)
						// scale image down to width; calculate the scaling factor
						shrinkWidth=common.DEVICE_X_RESOLUTION;
						shrinkHeight=width_ratio*tempImage.height;
					} else {
						shrinkWidth=height_ratio*tempImage.width;
						shrinkHeight=common.DEVICE_Y_RESOLUTION;
					}
					tempImage=common.scaleBitmap(tempImage, shrinkWidth, shrinkHeight);
				}
				
				//cropping image
				croppedImage.bitmapData.copyPixels(tempImage.bitmapData, 
					new Rectangle((tempImage.width-common.DEVICE_X_RESOLUTION)/2, (tempImage.height-common.DEVICE_Y_RESOLUTION)/2,common.DEVICE_X_RESOLUTION,common.DEVICE_Y_RESOLUTION),
					new Point(0,0));
				
				
			}else {
				return tempImage;
			}
			return croppedImage;
		}
		
		private function onloadRandomImage(event:Event):void {
			clearThumbAndPreview();
			// create the Loader Object from external source
			this.loadBitmapFromFile(this.getRandomImagePath());
		}
		
		private function onLoadPreviousImage(event:Event):void {
			clearThumbAndPreview();
			imageIndex--;
			if (imageIndex<1){
				imageIndex=this.MAX_IMAGE_INDEX; // loop back to the highest image number
			}
			this.loadBitmapFromFile("images/"+imageIndex+".jpg");
		}
		
		private function onLoadNextImage(event:Event):void {
			clearThumbAndPreview();
			imageIndex++;
			if (imageIndex>MAX_IMAGE_INDEX){
				imageIndex=1; // loop back to first image
			}
			this.loadBitmapFromFile("images/"+imageIndex+".jpg");
		}
		
		private function clearThumbAndPreview():void {
			hidePuzzlePreview();
			// update the preview and thumb puzzle images
			if(menu.contains(thumbPuzzleImage)){
				menu.removeChild(thumbPuzzleImage);
			}
			
			if(thumbPuzzleImage.numChildren >=1 ){
				thumbPuzzleImage.removeChildAt(0);
			}
			
			thumbPuzzleImage.removeEventListener(MouseEvent.CLICK, togglePuzzlePreview);
			
			if(this.contains(previewPuzzleImage)){
				this.removeChild(previewPuzzleImage);
			}
			
		}
		
		private function rbg1Change(e:MouseEvent):void {
			
			setPuzzleSize();
		}
		
		private function setPuzzleSize():void{
			
			if(rbg1.selection.label=="4x3"){
				xSize=4;
				ySize=3;
			}
			if(rbg1.selection.label=="5x4"){
				xSize=5;
				ySize=4;
			}
			if(rbg1.selection.label=="6x5"){
				xSize=6;
				ySize=5;
			}
			if(rbg1.selection.label=="9x7"){
				xSize=9;
				ySize=7;
			}	
			
		}
		
		private function newGameClicked(e:MouseEvent):void {
			setPuzzleSize();
			currentPuzzleImage = bitmapPuzzleImage;
			this.dispatchEvent(new Event("onNewGame"));
			hideMenu();
		}
		
		private function hideMenuClicked(e:MouseEvent):void {
			hideMenu();
		}
		
		private function showMenu():void{
			
			if (menuShown==true){
				return; //already shown don't do anything.
			}
			
			menuShown=true;
			
			if (currentPuzzleImage != null && currentPuzzleImage != bitmapPuzzleImage)
			{
				trace("reusing stored puzzle Image");
				clearThumbAndPreview();
				initPreviewThumb(currentPuzzleImage);
			}
			Tweener.addTween(menu, {y: -CORNER_RADIUS, time: 1});
		}
		
		private function togglePuzzlePreview(e:MouseEvent):void{
			
			if(previewShown){
				hidePuzzlePreview();
			}else{
				showPuzzlePreview();
			}
		
		}
		
		private function showPuzzlePreview():void{
			Tweener.addTween(previewPuzzleImage, 
				{x:(common.DEVICE_X_RESOLUTION-previewPuzzleImage.width)/2,
				 time: 1});
			previewShown=true;
		}
		
		private function hidePuzzlePreview():void{
			Tweener.addTween(previewPuzzleImage, {x: common.DEVICE_X_RESOLUTION +10, time: 1});
			previewShown=false;
		}
		
		private function hideMenu():void {		
			menuShown=false;
			// hide Puzzle Preview
			hidePuzzlePreview();
			// hide menu
			Tweener.addTween(menu, {y: -(MENU_HEIGHT+CORNER_RADIUS), time: 1});		
		}
		
		public function getImagePath():String {
			//choose a random image
			return getRandomImagePath();
		}
		
		private function getRandomImagePath():String{
			imageIndex=(Math.floor(Math.random()*MAX_IMAGE_INDEX)+1);
			return "images/"+imageIndex+".jpg";
		}
		
		public function getBitmapImage():Bitmap {
			return bitmapPuzzleImage;
		}
		
		public function getYsize():int{
			return ySize;
		}
		
		public function getXsize():int{
			return xSize;
		}
		
	}

}