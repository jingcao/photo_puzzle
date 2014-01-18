//Puzzles sizes: 9x7, 6x5, 5x4, 4x3
//Note: some methods are reused from book: "ActionScript 3.0 Game Programming University"
package
{
	
	import caurina.transitions.Tweener;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import qnx.ui.text.Label;
	
	public class SlidePuzzle extends Sprite
	{
		private var background:Sprite = new Sprite();
		
		// bitmaps
		private var croppedImage:Bitmap;
		
		// space between pieces and offset
		private static const spacing:Number = 2;
		private static const horizOffset:Number = 0;
		private static const vertOffset:Number = 0;
	
		// number of pieces
		private static var numPiecesHoriz:int;
		private static var numPiecesVert:int;
		
		// total grid spacing (sum of the total space taken by the grid lines in respective directions)
		private static var total_x_spacing:int;
		private static var total_y_spacing:int;
		
		// Puzzle Cropped Image Size
		private static var croppedHeight:int;
		private static var croppedWidth:int;
		
		// random shuffle steps
		private static var numShuffle:int;
		
		// animation steps and time
		private static const slideSteps:int = 10;
		private static const slideTime:int = 250;
		
		// size of pieces
		private var pieceWidth:Number;
		private var pieceHeight:Number;
		
		// game pieces
		private var puzzleObjects:Array;
		
		// tracking moves
		private var blankPoint:Point;
		private var slidingPiece:Object;
		private var slideDirection:Point;
		private var slideAnimation:Timer;
		
		// Loaders
		private var puzzleImage:Loader = new Loader();
		private var gameOvrLdr:Loader = new Loader();
		
		private var isMovingPuzzlePiece:int; // counts how many puzzle pieces are currently being moved
		private var isGameOver:Boolean; //1 if over 0 if not over
		
		public function SlidePuzzle(xPieces:int, yPieces:int, image:Bitmap)
		{
			isGameOver=false; // set flag to game not over.
			
			numPiecesHoriz=xPieces;
			numPiecesVert=yPieces;
			
			total_x_spacing = (numPiecesHoriz-1)*spacing;
			total_y_spacing = (numPiecesVert-1)*spacing;
			
			croppedHeight = common.DEVICE_Y_RESOLUTION-total_y_spacing;
			croppedWidth = common.DEVICE_X_RESOLUTION-total_x_spacing;
			
			numShuffle=10*numPiecesHoriz*numPiecesVert;		
			
			// blank spot is the bottom right
			blankPoint = new Point(numPiecesHoriz-1,numPiecesVert-1);
		
			// crop the image to fit the screen if required.
			cropImage(image);
			
			// setbackground
			setBackground();
			
			// cut into puzzle pieces
			makePuzzlePieces(croppedImage.bitmapData);
			 
			// scramble them
			scramblePuzzlePieces();
		}
		
		private function setBackground():void {
			background.graphics.beginFill(0x000000);
			background.graphics.drawRect(0,0,common.DEVICE_X_RESOLUTION,common.DEVICE_Y_RESOLUTION);
			background.graphics.endFill();
			
			for(var x:uint=0;x<numPiecesHoriz;x++) {
				for (var y:uint=0;y<numPiecesVert;y++) {
					// cereate the blank piece underneath (will show up when puzzle piece is moved)
					var blankPiece:Sprite=this.createBlankPiece(this.pieceWidth,this.pieceHeight);
					//background.setChildIndex(blankPiece,1);
					background.addChild(blankPiece);
					blankPiece.x = x*(pieceWidth+spacing) + horizOffset;
					blankPiece.y = y*(pieceHeight+spacing) + vertOffset;
				}
			}
			
			addChild(background);
		}
		
		// returns a white square box sprite that when seen, shows where the blank piece is located
		private function createBlankPiece(width:int, height:int):Sprite {
			var blankPiece:Sprite = new Sprite();
			var outline_tickness:int = 3;
			var outline_offset:int = 3;
			blankPiece.graphics.beginFill(0xFFFFFF);
			blankPiece.graphics.drawRect(outline_offset,outline_offset,width-2*outline_offset,height-2*outline_offset);
			blankPiece.graphics.endFill();
			blankPiece.graphics.beginFill(0x000000);
			blankPiece.graphics.drawRect(outline_tickness+outline_offset,outline_tickness+outline_offset,
				width - (2*(outline_tickness+outline_offset)), height - (2*(outline_tickness+outline_offset)));
			return blankPiece;
		}
		
		// get the bitmap from an external source
		/*
		public function loadBitmap(bitmapFile:String):void {
			puzzleImage.contentLoaderInfo.addEventListener(Event.COMPLETE, loadingDone);
			var request:URLRequest = new URLRequest(bitmapFile);
			puzzleImage.load(request);
		}
		*/
		
		// bitmap done loading, crop image *due to grid lines then find out the size of each image piece.
		public function cropImage(image:Bitmap):void {			
			croppedImage =  new Bitmap(new BitmapData(croppedWidth,croppedHeight));
			

			croppedImage.bitmapData.copyPixels(image.bitmapData,
					new Rectangle(total_x_spacing/2, total_y_spacing/2,croppedWidth,croppedHeight),
					new Point(0,0));

			pieceWidth = croppedImage.width/numPiecesHoriz;
			pieceHeight = croppedImage.height/numPiecesVert;
			
		}
		
		// cut bitmap into pieces
		public function makePuzzlePieces(bitmapData:BitmapData):void {				
			puzzleObjects = new Array();
			for(var x:uint=0;x<numPiecesHoriz;x++) {
				for (var y:uint=0;y<numPiecesVert;y++) {
					// skip blank spot
					if (blankPoint.equals(new Point(x,y))) continue;
					
					// create new puzzle piece bitmap and sprite
					var newPuzzlePieceBitmap:Bitmap = new Bitmap(new BitmapData(pieceWidth,pieceHeight));
					newPuzzlePieceBitmap.bitmapData.copyPixels(bitmapData,new Rectangle(x*pieceWidth,y*pieceHeight,pieceWidth,pieceHeight),new Point(0,0));
					var newPuzzlePiece:Sprite = new Sprite();
					newPuzzlePiece.addChild(newPuzzlePieceBitmap);
					addChild(newPuzzlePiece);
					
					// set location
					newPuzzlePiece.x = x*(pieceWidth+spacing) + horizOffset;
					newPuzzlePiece.y = y*(pieceHeight+spacing) + vertOffset;
					
					// create object to store in array
					var newPuzzleObject:Object = new Object();
					newPuzzleObject.currentLoc = new Point(x,y);
					newPuzzleObject.homeLoc = new Point(x,y);
					newPuzzleObject.piece = newPuzzlePiece;
					newPuzzlePiece.addEventListener(MouseEvent.CLICK,clickPuzzlePiece);
					puzzleObjects.push(newPuzzleObject);
				}
			}
		}
		
		// returns a puzzle piece object that has the currentLoc equal to "loc".
		private function getPuzzlePieceAtLocation(loc:Point):Object{
			for(var i:int=0;i<puzzleObjects.length;i++) {
				if (puzzleObjects[i].currentLoc.equals(loc)) {
					return puzzleObjects[i]; 
				}
			}
			
			trace("should never get here!");
			return null;
		}
		
		// make a number of random moves
		public function scramblePuzzlePieces():void {
			for(var i:int=0;i<numShuffle;i++) {
				scrambleRandom();
			}
			isMovingPuzzlePiece=0;
		}
		
		// random move
		public function scrambleRandom():void {
			// loop to find valid moves
			var validPuzzleObjects:Array = new Array();
			for(var i:uint=0;i<puzzleObjects.length;i++) {
				if (validMove(puzzleObjects[i]) != "none") {
					validPuzzleObjects.push(puzzleObjects[i]);
				}
			}
			// pick a random move
			var pick:uint = Math.floor(Math.random()*validPuzzleObjects.length);
			movePiece(validPuzzleObjects[pick],false);
		}
		
		public function validMove(puzzleObject:Object): String {
			// is the blank spot above
			if ((puzzleObject.currentLoc.x == blankPoint.x) &&
				(puzzleObject.currentLoc.y >= blankPoint.y+1)) {
				return "up";
			}
			// is the blank spot below
			if ((puzzleObject.currentLoc.x == blankPoint.x) &&
				(puzzleObject.currentLoc.y <= blankPoint.y-1)) {
				return "down";
			}
			// is the blank to the left
			if ((puzzleObject.currentLoc.y == blankPoint.y) &&
				(puzzleObject.currentLoc.x >= blankPoint.x+1)) {
				return "left";
			}
			// is the blank to the right
			if ((puzzleObject.currentLoc.y == blankPoint.y) &&
				(puzzleObject.currentLoc.x <= blankPoint.x-1)) {
				return "right";
			}
			// no valid moves
			return "none";
		}
		
		// puzzle piece clicked
		public function clickPuzzlePiece(event:MouseEvent):void {
			// find piece clicked and move it
			for(var i:int=0;i<puzzleObjects.length;i++) {
				if (puzzleObjects[i].piece == event.currentTarget && isMovingPuzzlePiece==0) {
					movePiece(puzzleObjects[i],true);
					//slidingPiece.isMoving=false;
					break;
				}
			}
		}
		
		// move a piece into the blank space
		private function movePiece(puzzleObject:Object, slideEffect:Boolean):void {
			if(isGameOver){ //don't remove any pieces if game is over.
				return;
			}
			// get direction of blank space
			switch (validMove(puzzleObject)) {
				case "up":
					movePieceInDirection(puzzleObject,0,-1,slideEffect);
					break;
				case "down":
					movePieceInDirection(puzzleObject,0,1,slideEffect);
					break;
				case "left":
					movePieceInDirection(puzzleObject,-1,0,slideEffect);
					break;
				case "right":
					movePieceInDirection(puzzleObject,1,0,slideEffect);
					break;
			}
		}
		
		// shifts puzzle piece (able to do multiple at a time)
		private function movePieceInDirection(puzzleObject:Object, dx:int,dy:int, slideEffect:Boolean):void {
			
			var distance:int=0; 
			var nextPuzzleObject:Object=null;
			var nextPuzzleIndex:int;
			isMovingPuzzlePiece++;
			//var currentPuzzleIndex:int; // index into the puzzleObjects array
			
			//currentPuzzleIndex = (puzzleObject.currentLoc.y*numPiecesHoriz)+puzzleObject.currentLoc.x;
			
			if (dx!=0){ // moving along x axis of blank
				distance = Math.abs(puzzleObject.currentLoc.x - Math.abs(blankPoint.x));
				nextPuzzleObject=getPuzzlePieceAtLocation(new Point(puzzleObject.currentLoc.x+dx,puzzleObject.currentLoc.y));
			}
			
			if (dy!=0){ // moving along y axis of blank
				distance = Math.abs(puzzleObject.currentLoc.y - Math.abs(blankPoint.y));
				nextPuzzleObject=getPuzzlePieceAtLocation(new Point(puzzleObject.currentLoc.x,puzzleObject.currentLoc.y+dy));
			}
			
			if (distance > 1){ // recusively move the other pieces inbetween current piece and the blank.
				
				movePieceInDirection(nextPuzzleObject, dx, dy, slideEffect);
			}
			
			puzzleObject.currentLoc.x += dx;
			puzzleObject.currentLoc.y += dy;
			blankPoint.x -= dx;
			blankPoint.y -= dy;
			
			// animate or not
			if (slideEffect) {
				// start animation
				startSlide(puzzleObject,dx*(pieceWidth+spacing),dy*(pieceHeight+spacing));
			} else {
				// no animation, just move
				puzzleObject.piece.x = puzzleObject.currentLoc.x*(pieceWidth+spacing) + horizOffset;
				puzzleObject.piece.y = puzzleObject.currentLoc.y*(pieceHeight+spacing) + vertOffset;
			}
		}
		
		// set up a slide
		public function startSlide(puzzleObject:Object, dx:Number, dy:Number):void {
			if (slideAnimation != null) slideDone(null);
			
			slidingPiece = puzzleObject;
			slideDirection = new Point(dx,dy);
			slideAnimation = new Timer(slideTime/slideSteps,slideSteps);
			slideAnimation.addEventListener(TimerEvent.TIMER,slidePiece);
			slideAnimation.addEventListener(TimerEvent.TIMER_COMPLETE,slideDone);
			slideAnimation.start();
		}
		
		// move one step in slide
		public function slidePiece(event:Event):void {
			slidingPiece.piece.x += slideDirection.x/slideSteps;
			slidingPiece.piece.y += slideDirection.y/slideSteps;
		}
		
		// complete slide
		public function slideDone(event:Event):void {
			slideAnimation.stop();
			slideAnimation = null;
			slidingPiece.piece.x = slidingPiece.currentLoc.x*(pieceWidth+spacing) + horizOffset;
			slidingPiece.piece.y = slidingPiece.currentLoc.y*(pieceHeight+spacing) + vertOffset;
			isMovingPuzzlePiece--;
			
			// check to see if puzzle is complete now
			if (!isGameOver && puzzleComplete()) {
				gameOver();
			}
		}
		
		// check to see if all pieces are in place
		public function puzzleComplete():Boolean {
			for(var i:int=0;i<puzzleObjects.length;i++) {
				if (!puzzleObjects[i].currentLoc.equals(puzzleObjects[i].homeLoc)) {
					return false;
				}
			}
			isGameOver=true;
			return true;
		}
		
		// remove all puzzle pieces
		public function clearPuzzle():void {
			var i:int;
			for (i=0; i<puzzleObjects.length; i++) {
				puzzleObjects[i].piece.removeEventListener(MouseEvent.CLICK,clickPuzzlePiece);
				removeChild(puzzleObjects[i].piece);
			}
			removeChild(background);
			puzzleObjects = null;
		}
		
		public function gameOver():void{
			var url:String = "images/Ending_Picture.png";
			var urlReq:URLRequest = new URLRequest(url);
			gameOvrLdr.load(urlReq);
			gameOvrLdr.y=common.DEVICE_Y_RESOLUTION;
			addChild(gameOvrLdr);
			Tweener.addTween(gameOvrLdr, {y: (common.DEVICE_Y_RESOLUTION - gameOvrLdr.height)/2-35, x: 60,  time: 2});
			gameOvrLdr.addEventListener(MouseEvent.CLICK, onHideEndPic);
		}
		
		private function onHideEndPic(e:MouseEvent):void{
			removeChild(gameOvrLdr);
		}
	}
}