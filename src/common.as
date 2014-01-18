package
{
	import mx.utils.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	import qnx.ui.text.Label;

	
	public class common
	{
		public static const DEVICE_X_RESOLUTION:int = 1024;
		public static const DEVICE_Y_RESOLUTION:int = 600;
		
		public static function scaleBitmap(obj:Bitmap, thumbWidth:Number, thumbHeight:Number):Bitmap {
			var m:Matrix = new Matrix();
			m.scale(thumbWidth / obj.width, thumbHeight / obj.height);
			var bmp:BitmapData = new BitmapData(thumbWidth, thumbHeight, true, 0x00000000); //support transparentcy
			bmp.draw(obj, m);
			return new Bitmap(bmp, "auto", true);
		}

		
		//debug output
		public static function getLabel(string:String):Label
		{
			// create a label
			var myLabel:Label = new Label();
			// set the label to appear at the center of the screen
			myLabel.x = (DEVICE_X_RESOLUTION - myLabel.width) /2;
			myLabel.y = (DEVICE_Y_RESOLUTION - myLabel.height) /2;
			// set the label text to "Hello, World!"
			myLabel.text = string;
			myLabel.width = myLabel.textWidth + 10;
			return myLabel
		}
		
		//returns a sprite that is an image with a boarder with a boarder
		public static function getImageWithBoarder(pic:Bitmap, boarderThickness:int, colour:Number):Sprite{
				var imageWithBoarder:Sprite = new Sprite();
				var outline_offset:int = boarderThickness;
				imageWithBoarder.graphics.beginFill(colour);
				imageWithBoarder.graphics.drawRect(0,0,pic.width+boarderThickness*2,pic.height+2*boarderThickness);
				imageWithBoarder.graphics.endFill();
				pic.x=boarderThickness;
				pic.y=boarderThickness;
				imageWithBoarder.addChild(pic);				
				return imageWithBoarder;
		}
		
		//removes child if found in the parent otherwise do nothing.
		/*
		public static function removeChild(parent:Object, childToRemove:DisplayObject):void{
			var n = parent.numChildren; 
			var child:DisplayObject;
			for (var i = 0; i<n; i++){
				child = this.getChildAt(i)
				if (ObjectUtil.compare(child, childToRemove) == 0){
					parent.removeChild(child);
				}
			}
		}
		*/

	}

}