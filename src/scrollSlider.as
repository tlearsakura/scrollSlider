package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import tle7.scrollSlider.Slider;
	import tle7.scrollSlider.SliderType;
	
	[SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class scrollSlider extends Sprite
	{
		private var slider1:Slider;
		private var slider2:Slider;
		
		public function scrollSlider()
		{
			slider1 = new Slider(700,100,SliderType.HORIZONTAL,10,1.1);
			slider1.touched.add(onTouched);
			slider1.x = 50;
			slider1.y = 20;
			slider1.changedPosition.add(onChangePosition1);
			var box:Box;
			for(var i:uint=1; i<=20; i++){
				box = new Box(Math.random()*uint.MAX_VALUE,60,50);
				slider1.addContent(box);
			}
			this.addChild(slider1);
			
			slider2 = new Slider(100,500,SliderType.VERTICAL,10,1.1);
			slider2.touched.add(onTouched);
			slider2.x = 50;
			slider2.y = 100;
			slider2.changedPosition.add(onChangePosition2);
			for(i=1; i<=20; i++){
				box = new Box(Math.random()*uint.MAX_VALUE,100,50);
				slider2.addContent(box);
			}
			this.addChild(slider2);
			
			slider1.position = .5;
		}
		
		private function onTouched(target:Object,slider:Slider):void
		{
			trace(target,slider);
		}
		
		private function onChangePosition1(val:Number):void
		{
			trace('slider1',val);
		}
		
		private function onChangePosition2(val:Number):void
		{
			trace('slider2',val);
		}
	}
}