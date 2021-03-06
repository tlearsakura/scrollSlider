package tle7.scrollSlider
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	public class Slider extends Sprite
	{
		private var mClip:Shape;
		private var plane:Shape;
		private var list:Sprite;
		
		private var startPressTime:Number;
		private var draging:Boolean = false;
		private var dragItem:Boolean = false;
		private var touchPoint:Point = new Point(), upPoint:Point = new Point();
		
		private var startP:Number;
		private var targetP:Number;
		private var lengthMouse:Number, half:Number;
		private var power:Number;
		private var _percent:Number = 0;
		private var _pHeight:Number;
		
		private var rect:Rectangle;
		private var type:String;
		private var typePos:String;
		private var typeSize:String;
		private var typeTouch:String;
		private var gap:Number;
		
		public var touched:Signal;
		public var changedPosition:Signal;
		
		public function Slider(width:Number,height:Number,type:String,gap:Number=0,power:Number=0)
		{
			touched = new Signal(Object,Slider);
			changedPosition = new Signal(Number);
			
			rect = new Rectangle(0,0,width,height);
			this.type = type;
			this.gap = gap;
			this.power = power;
			
			mClip = new Shape();
			mClip.graphics.beginFill(0);
			mClip.graphics.drawRect(0,0,width,height);
			mClip.graphics.endFill();
			this.addChild(mClip);
			
			plane = new Shape();
			plane.graphics.beginFill(0);
			plane.graphics.drawRect(0,0,width,height);
			plane.graphics.endFill();
			plane.alpha = 0;
			this.addChild(plane);
			
			list = new Sprite();
			this.addChild(list);
			
			this.mask = mClip;
			//mClip.mask = this;
			
			if(type=='horizontal'){
				typePos = 'x';
				typeSize = 'width';
				typeTouch = 'mouseX';
				half = width * .5;
			}else if(type=='vertical'){
				typePos = 'y';
				typeSize = 'height';
				typeTouch = 'mouseY';
				half = height * .5;
			}
			
			setSlide();
		}
		
		public function addContent(obj:DisplayObject):void {
			if(list.numChildren>0)
				obj[typePos] = list.getChildAt(list.numChildren-1)[typePos] + list.getChildAt(list.numChildren-1)[typeSize] + gap;
			list.addChild(obj);
			_pHeight = list[typeSize]-rect[typeSize];
		}
		
		public function get getRects():Rectangle {
			return rect;
		}
		
		public function get position():Number {
			return _percent;
		}
		
		public function set position(val:Number):void {
			draging = false;
			if(this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME,dragLoop);
			_percent = val;
			list[typePos] = -(_percent*_pHeight);
		}
		
		//////////////////////////////////////////////////////////
		///////////////////   touch  slide   /////////////////////
		//////////////////////////////////////////////////////////
		private function setSlide():void {
			this.addEventListener(MouseEvent.MOUSE_DOWN, touchScreen);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		protected function onMouseWheel(e:MouseEvent):void
		{
			if(draging) return;
			if(this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME,dragLoop);
			list[typePos] += e.delta*(rect[typeSize]/50);
			if(list[typePos] > 0) list[typePos] = 0;
			else if(list[typePos] < -(list[typeSize])+rect[typeSize]) list[typePos] = -(list[typeSize]) + rect[typeSize];
			_percent = Math.abs(list[typePos])/_pHeight;
			changedPosition.dispatch(_percent);
		}
		private function touchScreen(e:MouseEvent):void {
			if(e.type == MouseEvent.MOUSE_DOWN){
				stage.addEventListener(MouseEvent.MOUSE_UP, touchScreen);
				pressTag();
			}else if(e.type == MouseEvent.MOUSE_UP){
				stage.removeEventListener(MouseEvent.MOUSE_UP, touchScreen);
				dropThis(e.target as DisplayObject);
			}
		}
		
		protected function dragLoop(e:Event):void {
			if(draging){
				if(list[typePos] > 0){
					targetP = 0;
					list[typePos] = this[typeTouch] - lengthMouse;
					list[typePos] *= .5;
				}else if(list[typePos]+list[typeSize] < rect[typeSize]){
					targetP = -(list[typeSize]) + rect[typeSize];
					list[typePos] = this[typeTouch] - lengthMouse;
					list[typePos] -=((list[typePos]+list[typeSize]) - rect[typeSize]) * .5;
				}else list[typePos] = this[typeTouch] - lengthMouse;
				startPressTime = getTimer();
				startP = this[typeTouch];
			}else{
				if(list[typePos] > 0) targetP = 0;
				else if(list[typePos]+list[typeSize] < rect[typeSize]) targetP = -(list[typeSize]) + rect[typeSize];
				
				list[typePos] += (targetP-list[typePos])/10;
				if(Math.floor(list[typePos])==Math.floor(targetP) ||
					Math.floor(list[typePos])-1==Math.floor(targetP) ||
					Math.floor(list[typePos])+1==Math.floor(targetP)){
					list[typePos] = targetP;
					this.removeEventListener(Event.ENTER_FRAME,dragLoop);
				}
			}
			_percent = Math.abs(list[typePos])/_pHeight;
			changedPosition.dispatch(_percent);
		}
		protected function pressTag():void {
			lengthMouse = this[typeTouch] - list[typePos];
			startPressTime = getTimer();
			touchPoint.x = this.mouseX;
			touchPoint.y = this.mouseY;
			startP = this[typeTouch];
			draging = true;
			this.addEventListener(Event.ENTER_FRAME,dragLoop);
		}
		protected function dropThis(target:DisplayObject):void {
			if(draging){
				draging = false;
				var diffTime:Number = getTimer()-startPressTime;
				//trace(diffTime);
				/*if(diffTime > 250){
					targetP = list[typePos];
				}else if(diffTime < 80){*/
					upPoint.x = this.mouseX; upPoint.y = this.mouseY;
					if(Point.distance(touchPoint,upPoint) < 10) touched.dispatch(target,this);
					targetP = (list[typePos] + (this[typeTouch] - startP)) + ((this[typeTouch] - startP)*(100/diffTime)*power);
				//}
				if(list[typePos] > 0) targetP = 0;
				else if(list[typePos]+list[typeSize] < rect[typeSize]) targetP = -(list[typeSize]) + rect[typeSize];
			}
		}
		
		
		//////////////////////////
		public function clear():void {
			touched.removeAll();
			this.removeEventListener(MouseEvent.MOUSE_DOWN, touchScreen);
			stage.removeEventListener(MouseEvent.MOUSE_UP, touchScreen);
			this.removeEventListener(Event.ENTER_FRAME,dragLoop);
			this.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			this.removeChildren(0,this.numChildren-1);
			mClip = null;
			list = null;
		}
	}
}