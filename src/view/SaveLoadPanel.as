package view
{
	import com.glyf.ui.SlideSelector;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import model.SaveLoadService;
	
	import ui.ActiveFlag;
	import ui.SaveLoadGraphics;
	
	public class SaveLoadPanel extends Sprite
	{
		private var slots:Vector.<SlideSelector> = new Vector.<SlideSelector>;
		
		private var _data:SaveLoadService;
		
		
		public function SaveLoadPanel(data:SaveLoadService)
		{
			_data = data;
			
			_data.addEventListener(SaveLoadService.PATCHES_POPULATED, onPatchesReady);
			
//			slots[0].graphics.addEventListener(MouseEvent.CLICK, onDoubleClick);
		}
		
		protected function onPatchesReady(event:Event):void
		{
			_data.addEventListener(SaveLoadService.PATCH_SAVED, onPatchSaved);
			
			var l:int = _data.patches.length;
			
			for(var i:int=0; i<l; i++)
			{
				var slot:SlideSelector = new SlideSelector(new SaveLoadGraphics());
				
				slot.graphics.patchNum_txt.text = "PATCH "+i.toString();
				slot.graphics.label_txt.text = _data.patches[i].stamp;
				
				slot.addEventListener(SlideSelector.SELECT_0, onSaveSelect);
				slot.addEventListener(SlideSelector.SELECT_1, onLoadSelect);
				
				slot.graphics.x = (i % AppData.nPatchColumns) *120;
				slot.graphics.y = 60 + Math.floor(i/AppData.nPatchColumns)*60;
				
				slots.push(slot);
				
				addChild(slot.graphics);
			}
			
			setActiveSlot(-1);
			
		}
		
		protected function onDoubleClick(event:MouseEvent):void
		{
			trace("DOUBLE CLICK");
//			_data.createPresetsFileUtility();
//			_data.savePresetsFileToSharedObjects();
		}
		
		protected function onPatchSaved(event:Event):void
		{
			var l:int = _data.patches.length;
			
			for(var i:int=0; i<l; i++)
			{
				slots[i].graphics.label_txt.text = _data.patches[i].stamp;
			}
		}
		
		protected function onSaveSelect(event:Event):void
		{
			var idx:int = slots.indexOf(event.currentTarget);
			
			_data.save(idx);
			
			setActiveSlot(idx);
			
			setTimeout(slots[idx].returnFromSelection, 800);
		}
		
		protected function onLoadSelect(event:Event):void
		{
			var idx:int = slots.indexOf(event.currentTarget);
			
			_data.load(idx);
			
			setActiveSlot(idx);
			
			setTimeout(slots[idx].returnFromSelection, 800);
		}
		
		protected function setActiveSlot(idx:int):void
		{
			var l:int = _data.patches.length;
			
			for(var i:int=0; i<l; i++)
			{
				slots[i].graphics.activeColor.visible = (i == idx) ? true : false;
				
			}
			
			
		}
	}
}