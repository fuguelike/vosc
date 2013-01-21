package audio
{
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import flash.media.Sound;

	public class AudioData
	{
		
		public var lowFreqVal:Number;
		public var medFreqVal:Number;
		public var hiFreqVal:Number;
		
		private var _micBytes : ByteArray = new ByteArray();
		private var _micSound:Sound;
		
		public function AudioData()
		{
			_micSound = new Sound();
			_micSound.addEventListener(SampleDataEvent.SAMPLE_DATA, soundSampleDataHandler);
			
			var mic:Microphone = Microphone.getMicrophone(); 
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, updateSample); 
//			function micSampleDataHandler(event:SampleDataEvent):void { 
//				while(event.data.bytesAvailable)     { 
//					var sample:Number = event.data.readFloat(); 
////					soundBytes.writeFloat(sample); 
//				} 
//			}
				
		}
		
		protected function soundSampleDataHandler(event:SampleDataEvent):void
		{
			for (var i:int = 0; i < 8192 && _micBytes.bytesAvailable > 0; i++) {
				var sample:Number = _micBytes.readFloat();
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
		}
		
		public function updateSample(event:SampleDataEvent):void
		{
			_micBytes = event.data;
			
			_micSound.play();
//			// Get number of available input samples
//			var len:uint = event.data.length/4;
//			
//			// Read the input data and stuff it into 
//			// the circular buffer
//			for ( var i:uint = 0; i < len; i++ )
//			{
//				ba[i] = event.data.readFloat();
//				
//			}

		}
	}
}