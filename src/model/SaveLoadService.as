package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	import flash.globalization.LocaleID;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class SaveLoadService extends EventDispatcher
	{
		public static const PATCH_SAVED:String = "patchsaved";
		public static const PATCHES_POPULATED:String = "patchespopulated";
		
		public var patches:Vector.<PatchVO> = new Vector.<PatchVO>;
		
		public function SaveLoadService()
		{
		}
		
		public function init():void
		{
			var socheck:SharedObject = SharedObject.getLocal("VOSCPatch0");
			
			(socheck.data["time"]) ? populatePatches() : savePresetsFileToSharedObjects();
			
		}
		
		private function populatePatches():void
		{
			trace("populatePatches");
			
			for(var i:int=0; i<AppData.nPatches; i++)
			{
				var patch:PatchVO;
				var so:SharedObject = SharedObject.getLocal("VOSCPatch"+i.toString());
				
				if(so.data["time"])//check for SO existence
				{
//					trace(so.data["time"]);
					patch = patchFromSharedObject(so);
				}
				else
				{
					patch = new PatchVO();
				}
				patches.push(patch);
			}
			
			dispatchEvent(new Event(SaveLoadService.PATCHES_POPULATED));
		}
		
		private function patchFromSharedObject(so:SharedObject):PatchVO
		{
			var osc0VO:OscVO = new OscVO();
			osc0VO.radiusNormal = so.data["osc0Radius"];
			osc0VO.xType = so.data["osc0XType"];
			osc0VO.yType = so.data["osc0YType"];
			osc0VO.periodNormal = so.data["osc0Period"];
			osc0VO.modAmpNormal = so.data["osc0ModAmp"];
			osc0VO.modSpeedNormal = so.data["osc0ModSpeed"];
			osc0VO.modTime = so.data["osc0ModTime"];
			
			var osc1VO:OscVO = new OscVO();
			osc1VO.radiusNormal = so.data["osc1Radius"];
			osc1VO.xType = so.data["osc1XType"];
			osc1VO.yType = so.data["osc1YType"];
			osc1VO.periodNormal = so.data["osc1Period"];
			osc1VO.modAmpNormal = so.data["osc1ModAmp"];
			osc1VO.modSpeedNormal = so.data["osc1ModSpeed"];
			osc1VO.modTime = so.data["osc1ModTime"];
			
			var osc2VO:OscVO = new OscVO();
			osc2VO.radiusNormal = so.data["osc2Radius"];
			osc2VO.xType = so.data["osc2XType"];
			osc2VO.yType = so.data["osc2YType"];
			osc2VO.periodNormal = so.data["osc2Period"];
			osc2VO.modAmpNormal = so.data["osc2ModAmp"];
			osc2VO.modSpeedNormal = so.data["osc2ModSpeed"];
			osc2VO.modTime = so.data["osc2ModTime"];
			
			var osc3VO:OscVO = new OscVO();
			osc3VO.radiusNormal = so.data["osc3Radius"];
			osc3VO.xType = so.data["osc3XType"];
			osc3VO.yType = so.data["osc3YType"];
			osc3VO.periodNormal = so.data["osc3Period"];
			osc3VO.modAmpNormal = so.data["osc3ModAmp"];
			osc3VO.modSpeedNormal = so.data["osc3ModSpeed"];
			osc3VO.modTime = so.data["osc3ModTime"];
			
			var patchVO:PatchVO = new PatchVO();
			patchVO.idx = so.data["idx"];
			patchVO.stamp = so.data["stamp"];
			patchVO.time = so.data["time"];
			patchVO.resolution = so.data["resolution"];
			patchVO.colorIndex = so.data["colorIndex"];
			patchVO.colorInvert = so.data["colorInvert"];
			patchVO.osc0 = osc0VO;
			patchVO.osc1 = osc1VO;
			patchVO.osc2 = osc2VO;
			patchVO.osc3 = osc3VO;
			
//			trace("PATCH FROM SO "+so.data["idx"]);
			
			return patchVO;
		}
		
		public function load(idx:int):void
		{
			var so:SharedObject = SharedObject.getLocal("VOSCPatch"+idx.toString());
			
			Data.getInstance().setPatch(patchFromSharedObject(so));
		}
		
		public function save(idx:int):void
		{
//			trace("SAVE DATA");
			var so:SharedObject = SharedObject.getLocal("VOSCPatch"+idx.toString());
			
//			var patch:PatchVO = patches[idx];
			
			var d:Data = Data.getInstance();
			
			var date:Date = new Date();
			
			var ampm:String = (Math.floor(date.hours/12) > 0) ? "PM" : "AM";
			
			var hour:String = (date.hours == 0 || date.hours == 12) ? "12" : (date.hours%12).toString();
			var minute:String = (date.minutes < 10) ? "0" : "" + date.minutes.toString();
			
			so.data["idx"] = d.vo.idx;
			so.data["stamp"] = (date.month+1).toString()+"/"+date.date.toString()+" "+hour+":"+minute+" "+ampm;
			so.data["time"] = d.vo.time;
			so.data["resolution"] = d.vo.resolution;
			so.data["colorIndex"] = d.vo.colorIndex;
			so.data["colorInvert"] = d.vo.colorInvert;
			
			so.data["osc0Radius"] = d.vo.osc0.radiusNormal;
			so.data["osc0XType"] = d.vo.osc0.xType;
			so.data["osc0YType"] = d.vo.osc0.yType;
			so.data["osc0Period"] = d.vo.osc0.periodNormal;
			so.data["osc0ModAmp"] = d.vo.osc0.modAmpNormal;
			so.data["osc0ModSpeed"] = d.vo.osc0.modSpeedNormal;
			so.data["osc0ModTime"] = d.vo.osc0.modTime;
			
			so.data["osc1Radius"] = d.vo.osc1.radiusNormal;
			so.data["osc1XType"] = d.vo.osc1.xType;
			so.data["osc1YType"] = d.vo.osc1.yType;
			so.data["osc1Period"] = d.vo.osc1.periodNormal;
			so.data["osc1ModAmp"] = d.vo.osc1.modAmpNormal;
			so.data["osc1ModSpeed"] = d.vo.osc1.modSpeedNormal;
			so.data["osc1ModTime"] = d.vo.osc1.modTime;
			
			so.data["osc2Radius"] = d.vo.osc2.radiusNormal;
			so.data["osc2XType"] = d.vo.osc2.xType;
			so.data["osc2YType"] = d.vo.osc2.yType;
			so.data["osc2Period"] = d.vo.osc2.periodNormal;
			so.data["osc2ModAmp"] = d.vo.osc2.modAmpNormal;
			so.data["osc2ModSpeed"] = d.vo.osc2.modSpeedNormal;
			so.data["osc2ModTime"] = d.vo.osc2.modTime;
			
			so.data["osc3Radius"] = d.vo.osc3.radiusNormal;
			so.data["osc3XType"] = d.vo.osc3.xType;
			so.data["osc3YType"] = d.vo.osc3.yType;
			so.data["osc3Period"] = d.vo.osc3.periodNormal;
			so.data["osc3ModAmp"] = d.vo.osc3.modAmpNormal;
			so.data["osc3ModSpeed"] = d.vo.osc3.modSpeedNormal;
			so.data["osc3ModTime"] = d.vo.osc3.modTime;
			
			patches[idx] = patchFromSharedObject(so);
			
			dispatchEvent(new Event(PATCH_SAVED));
			
			trace("data saved");
		}
		
		
		
		public function savePresetsFileToSharedObjects():void
		{
			trace("savePresetsFileToSharedObjects");
			var ldr:URLLoader = new URLLoader();
			ldr.dataFormat = URLLoaderDataFormat.BINARY;
			ldr.addEventListener(Event.COMPLETE, onLoaded);
			ldr.load(new URLRequest("assets/vosc.dat"));
			
			
			function onLoaded(e:Event):void
			{
//				trace("PRESETS LOADED");
				var ba:ByteArray = ldr.data as ByteArray;
				ba.position = 0;
				for(var i:int=0; i<AppData.nPatches; i++)
				{
					var o:Object = ba.readObject();
					var so:SharedObject = SharedObject.getLocal("VOSCPatch"+i.toString());					
					for (var props:* in o) 
					{
						so.data[props] = o[props];
//						trace(props,o[props]);
					}
					
					so.data["stamp"] = "PRESET"+i.toString();
				}
				populatePatches();
			}
		}
	}
}