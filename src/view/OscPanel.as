package view
{
	import com.glyf.ui.TouchComboBox;
	import com.glyf.ui.TouchSlider;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import model.OscData;
	
	import ui.OscPanelGraphics;
	import com.glyf.ui.TouchSlider2Way;

	public class OscPanel extends Sprite
	{
		private var _g:OscPanelGraphics;
		private var data:OscData;
		private var _rSlider:TouchSlider;
		private var _xPicker:TouchComboBox;
		private var _yPicker:TouchComboBox;
		private var _pSlider:TouchSlider;
		private var _sSlider:TouchSlider;
		private var _aSlider:TouchSlider;
		
		public function OscPanel(data:OscData)
		{
			this.data = data;
			
			data.addEventListener(OscData.UPDATE_PATCH, onPatchUpdate);
			
			_g = new OscPanelGraphics();
			addChild(_g);
		}
		
		protected function onPatchUpdate(event:Event):void
		{
			_rSlider.setValue(data.vo.radiusNormal);
			_xPicker.setValue(data.vo.xType);
			_yPicker.setValue(data.vo.yType);
			_pSlider.setValue(data.vo.periodNormal);
			_sSlider.setValue(data.vo.modSpeedNormal);
			_aSlider.setValue(data.vo.modAmpNormal);
		}
		
		public function init():void
		{
			_rSlider = new TouchSlider2Way(_g.radiusSlider);
			_rSlider.addEventListener(TouchSlider.UPDATE, updateRadius);
			_rSlider.init();
			
			_xPicker = new TouchComboBox(Vector.<MovieClip>([
				_g.xType1, _g.xType2, _g.xType3, _g.xType4, _g.xType5, _g.xType6
			]));
			_xPicker.addEventListener(TouchComboBox.UPDATE, updateXType);
			_xPicker.init();
			
			_yPicker = new TouchComboBox(Vector.<MovieClip>([
				_g.yType1, _g.yType2, _g.yType3, _g.yType4, _g.yType5, _g.yType6
			]));
			_yPicker.addEventListener(TouchComboBox.UPDATE, updateYType);
			_yPicker.init();
			
			_pSlider = new TouchSlider(_g.periodSlider);
			_pSlider.addEventListener(TouchSlider.UPDATE, updatePeriod);
			_pSlider.init();
			
			_sSlider= new TouchSlider(_g.modspeedSlider);
			_sSlider.addEventListener(TouchSlider.UPDATE, updateModSpeed);
			_sSlider.init();
			
			_aSlider = new TouchSlider(_g.modampSlider);
			_aSlider.addEventListener(TouchSlider.UPDATE, updateModAmp);
			_aSlider.init();
			
		}
		
		protected function updateYType(event:Event):void
		{
			data.setTrigFuncY( TouchComboBox(event.currentTarget).value);
		}
		
		protected function updateXType(event:Event):void
		{			
			data.setTrigFuncX( TouchComboBox(event.currentTarget).value);
		}
		
		protected function updateRadius(event:Event):void
		{
			data.setRadiusNormal(TouchSlider(event.currentTarget).valueNormal);
		}
		
		private function updatePeriod(event:Event):void
		{
			data.setPeriodNormal(TouchSlider(event.currentTarget).valueNormal);
		}
		
		protected function updateModSpeed(event:Event):void
		{
			data.setModSpeedNormal(TouchSlider(event.currentTarget).valueNormal);
		}
		
		protected function updateModAmp(event:Event):void
		{
			data.setModAmpNormal(TouchSlider(event.currentTarget).valueNormal);
		}
		
		public function setTitle(i:int):void
		{
//			_g.oscNum_txt.text = i.toString();
		}
	}
}