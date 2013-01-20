package view
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import model.Data;
	
	import ui.ContractButton;
	import ui.EmptyButton;
	import ui.InvertButton;

	public class ColorPickerPanel extends Sprite
	{
//		private var bgColors:Vector.<uint>;
//		private var fgColors:Vector.<uint>;
		private var swatches:Array = [];
		
		
		public function ColorPickerPanel(fgColors:Vector.<uint>, bgColors:Vector.<uint>)
		{
//			addChild(new ContractButton());
			
//			trace("LENGTH"+bgColors.length);
			for(var i:int=0; i<bgColors.length; i++)
			{
				 var swatch:Sprite = new Sprite();
				 
				 swatch.graphics.beginFill(fgColors[i]);
				 swatch.graphics.moveTo(1,1);
				 swatch.graphics.lineTo(59,1);
				 swatch.graphics.lineTo(1,59);
				 swatch.graphics.lineTo(1,1);
				 swatch.graphics.endFill();
				 
				 swatch.graphics.beginFill(bgColors[i]);
				 swatch.graphics.moveTo(59,1);
				 swatch.graphics.lineTo(59,59);
				 swatch.graphics.lineTo(1,59);
				 swatch.graphics.lineTo(59,1);
				 swatch.graphics.endFill();
				 
				 swatch.addChild(new EmptyButton());
				 
				 swatch.x = 1+ (i % 7) *60;
				 swatch.y = 61 + Math.floor(i/7)*60;
				 
				 swatches.push(swatch);
				 
				 swatch.addEventListener(MouseEvent.CLICK, onSwatchSelect);
				 
				 addChild(swatch);
			}
			
			var invertBtn:InvertButton = new InvertButton();
			invertBtn.y = 60 + Math.ceil(bgColors.length/7) * 60;
			invertBtn.addEventListener(MouseEvent.CLICK, onInvertClick);
			addChild(invertBtn);
		}
		
		protected function onInvertClick(event:MouseEvent):void
		{
			Data.getInstance().setColorsInvert();
		}
		
		protected function onSwatchSelect(event:MouseEvent):void
		{
			Data.getInstance().setColorIndex(swatches.indexOf(event.currentTarget));
		}
	}
}