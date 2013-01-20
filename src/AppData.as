package
{
	public class AppData
	{
		public static var bufferSize:int = 1024;
		
		public static var nPatches:int = 48;
		public static var nPatchColumns:int = 7;
		
		public static var narrowDim:Number;
		public static var wideDim:Number;
		public static var uiScale:Number = 1;
		
		public static var MIN_RESOLUTION:int = 0;
		public static var MAX_RESOLUTION:int = 10;
		public static var DEFAULT_RESOLUTION:int = 2;
		
		public static const OSC_RADIUS_L_SCALE:int = 1;
		public static const OSC_PERIOD_L_SCALE:int = 5;
		public static const OSC_MODSPEED_L_SCALE:int = 5;
		
		
		public function AppData()
		{
			
		}
		
		public static function normalToExpScale(value:Number, power:Number):Number
		{
			return -.1+ Math.pow(10, -1+value*power);
		}
		
	}
}