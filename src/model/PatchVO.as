package model
{
	public class PatchVO
	{
		public var idx:int=0;
		public var stamp:String = "[EMPTY]";
		public var time:Number = 0;
		public var resolution:int = 1;
		public var colorInvert:Boolean = false;
		public var colorIndex:int = 0;
		
		public var osc0:OscVO;
		public var osc1:OscVO;
		public var osc2:OscVO;
		public var osc3:OscVO;
		
		
		
//		public var osc2Radius:Number;
//		public var osc2XType:int;
//		public var osc2YType:int;
//		public var osc2Period:Number;
//		public var osc2ModAmp:Number;
//		public var osc2ModSpeed:Number;
//		
//		public var osc3Radius:Number;
//		public var osc3XType:int;
//		public var osc3YType:int;
//		public var osc3Period:Number;
//		public var osc3ModAmp:Number;
//		public var osc3ModSpeed:Number;
//		
//		public var osc4Radius:Number;
//		public var osc4XType:int;
//		public var osc4YType:int;
//		public var osc4Period:Number;
//		public var osc4ModAmp:Number;
//		public var osc4ModSpeed:Number;
		
		public function PatchVO()
		{
		}
	}
}