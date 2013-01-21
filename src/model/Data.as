package model
{
	import com.gskinner.motion.GTween;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import audio.AudioData;

	public class Data extends EventDispatcher
	{
			
		public var numPoints:int;
		
		public var increment:Number;
		
		public var stageW:int;
		public var stageH:int;
		
		private static var instance:Data;
		
		public static const UPDATE_SHADER:String = "shaderupdate";
		public static const UPDATE_VERTEX:String = "vertexupdate";
		public static const UPDATE_FILTER:String = "filterupdate";
		public static const UPDATE_TIME:String = "timeupdate";
		
		public const timeStep:Number = .00001;
		
		public var loopNumVec:Vector.<Number>;
		
		public var oscDatas:Vector.<OscData> = new Vector.<OscData>;
		
		private var _bloomFilterEnabled:Boolean = false;
		private var _trailFilterEnabled:Boolean = false;
		
		public var vo:PatchVO = new PatchVO();
		
		public var bgColors:Vector.<uint> = Vector.<uint>(
			[0x000000,0x300000,0x210021,0x63140E,0x000027,0x374141,0x323858,
			0x002C2B,0x002100,0x040023,0x4D0000,0x491600,0x4E4200,0x39180C,
			0x146659,0x990000,0xFF0000,0xFFFFFF,0x333333,0x263331,0xCBD1DD,
			0xFF9900,0x0066CC,0xCC0033,0xCCFF33,0x000099,0x002AFF,0xFFB51B,
			0xC64353,0x95744F,0x665362,0xDBD7C1,0x190011,0xFFCC99,0x99CC99
			]
		);
		public var fgColors:Vector.<uint> = Vector.<uint>(
			[0xFFFFFF,0xE4ACAC,0xC0FF45,0x66FFFF,0xFDFF72,0xE8D9EE,0xFF9999,
			0x77FFFF,0x33FF99,0x8FA1FF,0xFF0000,0xFF662C,0xFFE587,0xC26306,
			0xFEFFB2,0xFF9900,0x99FFFF,0xCCCCCC,0x99CCCC,0xDCD2BC,0x09361A,
			0x22FFCC,0x99FF00,0xE6FF00,0xFF9900,0xFF0034,0xE7FF55,0xEC00FF,
			0xFFD5D2,0xFFFFFF,0xFFFBD8,0xFF2000,0xC5F0F6,0xDB3333,0x000A28
			]
		);
		
		public var bgR:Number = 0;
		public var bgG:Number = 0;
		public var bgB:Number = 0;
		public var fgR:Number = 1;
		public var fgG:Number = 1;
		public var fgB:Number = 1;
		
		
		public function Data()
		{
		}
		
		public static function getInstance():Data
		{
			if(instance)
			{
				return instance;
			}
			else
			{
				instance = new Data();
				instance.setResolution(AppData.DEFAULT_RESOLUTION);
				return instance;
			}
			
		}
		
		public function init(oscillatorData:Vector.<OscData>, audioData:AudioData):void
		{
			oscDatas = oscillatorData;
			
			for(var i:int=0; i<oscDatas.length; i++)
			{
				oscDatas[i].addEventListener(OscData.UPDATE_SHADER, onUpdateShader);
			}
			
			
			vo.osc0 = oscDatas[0].vo;
			vo.osc1 = oscDatas[1].vo;
			vo.osc2 = oscDatas[2].vo;
			vo.osc3 = oscDatas[3].vo;
		}
		
		public function setPatch(patchVO:PatchVO):void
		{
			trace("SET PATCH");
			
			vo = patchVO;
			
			oscDatas[0].setPatch(patchVO.osc0);
			oscDatas[1].setPatch(patchVO.osc1);
			oscDatas[2].setPatch(patchVO.osc2);
			oscDatas[3].setPatch(patchVO.osc3);
			
			setColorIndex(vo.colorIndex);
			
			setResolution(vo.resolution);
		}
		
		
		
		public function setColorIndex(idx:uint):void
		{
			
			if(!vo.colorInvert)
			{
				new GTween(this, .4, {
					bgR: ((bgColors[idx] >> 16) & 0xFF) / 255,
					bgG: ((bgColors[idx] >> 8) & 0xFF) / 255,
					bgB: (bgColors[idx] & 0xFF) / 255,
					fgR: ((fgColors[idx] >> 16) & 0xFF) / 255,
					fgG: ((fgColors[idx] >> 8) & 0xFF) / 255,
					fgB: (fgColors[idx] & 0xFF) / 255
				});
			}
			else
			{
				new GTween(this, .4, {
					fgR: ((bgColors[idx] >> 16) & 0xFF) / 255,
					fgG: ((bgColors[idx] >> 8) & 0xFF) / 255,
					fgB: (bgColors[idx] & 0xFF) / 255,
					bgR: ((fgColors[idx] >> 16) & 0xFF) / 255,
					bgG: ((fgColors[idx] >> 8) & 0xFF) / 255,
					bgB: (fgColors[idx] & 0xFF) / 255
				});
			}
			
			
			vo.colorIndex = idx;
			
			vo.colorIndex = idx;
			
//			dispatchEvent(new Event(Data.UPDATE_VERTEX));
		}
		
		public function setColorsInvert():void
		{
			vo.colorInvert = !vo.colorInvert;
			
			setColorIndex(vo.colorIndex);
		}
		
		public function updateTime():void
		{ 	
			vo.time += timeStep;
			
			loopNumVec = Vector.<Number>(
				//[ 1, Math.sin(time/3)*3, Math.tan(time/7)*50, Math.tan(5+time/9)*150]
				[oscDatas[0].getPeriod(timeStep), oscDatas[1].getPeriod(timeStep), oscDatas[2].getPeriod(timeStep), oscDatas[3].getPeriod(timeStep)]
			);
//			trace(oscDatas[0].getPeriod(timeStep));
			dispatchEvent(new Event(UPDATE_TIME));
		}
		
		protected function onUpdateShader(event:Event):void
		{
			dispatchEvent(new Event(UPDATE_SHADER));
		}
		
		private function setResolution(res:int):void
		{
			trace("RES: "+res);
			if(res > AppData.MAX_RESOLUTION) res = AppData.MAX_RESOLUTION;
			if(res < AppData.MIN_RESOLUTION) res = AppData.MIN_RESOLUTION;
			
			trace("SET RES: "+res);
			
			vo.resolution = res;
			
			numPoints = 16000*Math.pow(2, res);
			increment = Math.PI*2/numPoints;
			
			dispatchEvent(new Event(Data.UPDATE_VERTEX));
		}
		
		public function increasePoints():void
		{
			trace("INCREASE from "+vo.resolution);
			
			setResolution(vo.resolution+1);
		}
		
		public function decreasePoints():void
		{
			trace("DECREASE");
			
			setResolution(vo.resolution-1);
		}
		
		public function updateBloomFilter(enabled:Boolean):void
		{
			_bloomFilterEnabled = enabled;
			dispatchEvent(new Event(UPDATE_FILTER));
		}
		
		public function getBloomFilterEnabled():Boolean
		{
			return _bloomFilterEnabled;
		}
		
		public function updateTrailFilter(enabled:Boolean):void
		{
			_trailFilterEnabled = enabled;
			dispatchEvent(new Event(UPDATE_FILTER));
		}
		
		public function getTrailFilterEnabled():Boolean
		{
			return _trailFilterEnabled;
		}
	}
}