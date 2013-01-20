package view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ui.ContractButton;
	import ui.ExpandButton;
	
	public class MenuItemContainer extends Sprite
	{
		private var _item:Sprite;
		
		private var _g:ExpandButton;
		private var _g2:ContractButton;
		
		private var _expanded:Boolean = false;
		
		public static const EXPAND:String = "expand";
		public static const CONTRACT:String = "contract";
		
		public function MenuItemContainer(menuItem:Sprite, label:String = "")
		{
			_item = menuItem;
			
			_g = new ExpandButton();
			_g.label_txt.text = label;
			addChild(_g);
			
			_g2 = new ContractButton();
			_g2.label_txt.text = label;
			addChild(_g2);
			_g2.visible = false;
			
			_g.addEventListener(MouseEvent.CLICK, onExpandClick);
			_g2.addEventListener(MouseEvent.CLICK, onContractClick);
		}
		
		protected function onContractClick(event:MouseEvent):void
		{
			contract();
			dispatchEvent(new Event(CONTRACT));
		}
		
		protected function onExpandClick(event:MouseEvent):void
		{
			expand();
			dispatchEvent(new Event(EXPAND));
		}
		
		public function expand():void
		{
			if(_expanded) return;
			_expanded = true;
//			_g.alpha = 0;
			_g2.visible = true;
			
			_item.x = -x;
			
			addChildAt(_item, 0);
		}
		
		public function contract():void
		{
			if(!_expanded) return;
			_expanded = false;
			_g2.visible = false;
//			_g.alpha = 1;
			removeChild(_item);
		}
	}
}