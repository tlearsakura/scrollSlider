package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public final class Box extends Sprite
	{
		public function Box(color:uint,width:Number,height:Number)
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(color);
			shape.graphics.drawRect(0,0,width,height);
			shape.graphics.endFill();
			this.addChild(shape);
		}
	}
}