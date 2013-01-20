package view
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import model.Data;
	
	import ui.DecreaseButton;
	import ui.IncreaseButton;
	import ui.ResolutionField;
	
	public class ResolutionPanel extends Sprite
	{
		private var rField:ResolutionField;
		
		public function ResolutionPanel()
		{
			var iBtn:Sprite = new Sprite();
			iBtn.addChild(new IncreaseButton());
			iBtn.y = 60;
			addChild(iBtn);
			
			var dBtn:Sprite = new Sprite();
			dBtn.addChild(new DecreaseButton());
			dBtn.x = 300;
			dBtn.y = 60;
			addChild(dBtn);
			
			iBtn.addEventListener(MouseEvent.CLICK, onIncrease);
			dBtn.addEventListener(MouseEvent.CLICK, onDecrease);
			
			rField = new ResolutionField();
			rField.x = 120;
			rField.y = 60;
			rField.particles_txt.text = Data.getInstance().numPoints.toString();
			addChild(rField);
			
			Data.getInstance().addEventListener(Data.UPDATE_VERTEX, onResChange);
		}
		
		protected function onResChange(event:Event):void
		{
			rField.particles_txt.text = Data.getInstance().numPoints.toString();
		}
		
		protected function onDecrease(event:MouseEvent):void
		{
			Data.getInstance().decreasePoints();
		}
		
		protected function onIncrease(event:MouseEvent):void
		{
			Data.getInstance().increasePoints();
		}
	}
}