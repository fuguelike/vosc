package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class OscData extends EventDispatcher
	{
		public static const UPDATE_SHADER:String = "updateshader";
		public static const UPDATE_PATCH:String = "updatepatch";
		
		public var radius:Number; // accessed by core renderer
		
		private var period:Number;
		private var modAmp:Number;
		private var modSpeed:Number;
		private var modSpeedNormal:Number;
		private var radiusNormal:Number;
		
		public var vo:OscVO;
		
		public function OscData(vo:OscVO)
		{
			setPatch(vo);
		}
		
		public function setPatch(vo:OscVO):void
		{
			this.vo = vo;
			
			setPeriodNormal(vo.periodNormal);
			setModSpeedNormal(vo.modSpeedNormal);
			setModAmpNormal(vo.modAmpNormal);
			setRadiusNormal(vo.radiusNormal);
			setModTime(vo.modTime);
			
			dispatchEvent(new Event(UPDATE_SHADER));
			dispatchEvent(new Event(UPDATE_PATCH));
		}
		
		public function setModAmpNormal(valueNormal:Number):void
		{
			vo.modAmpNormal = valueNormal;
			
			modAmp = valueNormal;
//			trace(modAmp);
		}
		
		public function setTrigFuncX(val:int):void
		{
			vo.xType = val;
			//trace("SET TRIG X: "+val);
			dispatchEvent(new Event(UPDATE_SHADER));
		}
		
		public function setTrigFuncY(val:int):void
		{
			vo.yType = val;
			
			dispatchEvent(new Event(UPDATE_SHADER));
		}
		
		public function setPeriodNormal(valueNormal:Number):void
		{
			vo.periodNormal = valueNormal;
			
			period = AppData.normalToExpScale(valueNormal, AppData.OSC_PERIOD_L_SCALE);
//			trace(period);
		}
		
		public function setModSpeedNormal(valueNormal:Number):void
		{
			vo.modSpeedNormal = valueNormal;
			
			modSpeed = AppData.normalToExpScale(valueNormal, AppData.OSC_MODSPEED_L_SCALE);
//			trace(modSpeed);
		}
		
		public function setModTime(value:Number):void
		{
//			trace("SET MOD TIME: "+value);
			vo.modTime = value;
		}
		
		public function setRadiusNormal(valueNormal:Number):void
		{
			vo.radiusNormal = valueNormal;
//			trace(valueNormal);
			
			if(valueNormal < 0)
			{
				radius = -AppData.normalToExpScale(-valueNormal, AppData.OSC_RADIUS_L_SCALE);
			}
			else
			{
				radius = AppData.normalToExpScale(valueNormal, AppData.OSC_RADIUS_L_SCALE);
			}
			
//			trace(radius);
		}
		
		public function getPeriod(timeStep:Number):Number
		{
			var p:Number;
			
			vo.modTime += modSpeed*timeStep;
			
			p = period + Math.sin(vo.modTime) * modAmp * period;
			
			return p;
		}
		

	}
}