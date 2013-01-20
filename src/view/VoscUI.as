package view
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class VoscUI extends Sprite
	{
		private var items:Vector.<MenuItemContainer> = new Vector.<MenuItemContainer>;
		
		public function VoscUI()
		{
			super();
//			alpha = .5;
		}
		
		public function addItem(item:Sprite, label:String=""):void
		{
//			trace("ADD MENU ITEM");
			
			var menuItem:MenuItemContainer = new MenuItemContainer(item, label);
			menuItem.addEventListener(MenuItemContainer.EXPAND, onItemExpand);
			menuItem.addEventListener(MenuItemContainer.CONTRACT, onItemContract);
			items.push(menuItem);
			addChild(menuItem);
			
			updateItems();
		}
		
		protected function onItemContract(event:Event):void
		{
			updateItems();
		}
		
		protected function onItemExpand(event:Event):void
		{
			var l:int = items.length;
			
			for(var i:int=0; i<items.length; i++)
			{
				if(items[i] != event.currentTarget) items[i].contract();
			}
			updateItems();
		}
		
		protected function updateItems():void
		{
			var l:int = items.length;
			var xPos:Number = 0;
			
			for(var i:int=0; i<items.length; i++)
			{
				items[i].x = xPos;
				
				xPos += 60;//items[i].width;
//				trace("X: "+xPos);
			}
		}
	}
}