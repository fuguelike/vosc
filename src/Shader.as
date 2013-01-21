package
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import model.Data;

	public class Shader
	{
		public var vertexShaderAssembler:AGALMiniAssembler;
		public var fragmentShaderAssembler:AGALMiniAssembler;
		private var data:Data;
		
		public function Shader()
		{
			data = Data.getInstance();
		}
		
		public function uploadTo(program:Program3D):void
		{
			vertexShaderAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				
				"mul vt0.x, va2.x, vc0.x \n"+  //va2.x is the original position of the vertex, from 0 to 1
				"mul vt0.y, va2.x, vc0.y \n"+  // this puts the varius "loop" numbers in vt0
				"mul vt0.z, va2.x, vc0.z \n"+
				"mul vt0.w, va2.x, vc0.w \n"+
				
				trig(data.vo.osc0.xType, "vt1.x", "vt0.x")+ //apply the periodic function
				trig(data.vo.osc0.yType, "vt1.y", "vt0.x")+
				"mul vt1.x, vt1.x, vc1.x \n"+ //multiply by the radius
				"mul vt1.y, vt1.y, vc1.x \n"+
				
				trig(data.vo.osc1.xType, "vt2.x", "vt0.y")+
				trig(data.vo.osc1.yType, "vt2.y", "vt0.y")+
				"mul vt2.x, vt2.x, vc1.y \n"+
				"mul vt2.y, vt2.y, vc1.y \n"+
				
				trig(data.vo.osc2.xType, "vt3.x", "vt0.z")+
				trig(data.vo.osc2.yType, "vt3.y", "vt0.z")+
				"mul vt3.x, vt3.x, vc1.z \n"+
				"mul vt3.y, vt3.y, vc1.z \n"+
				
				trig(data.vo.osc3.xType, "vt4.x", "vt0.w")+
				trig(data.vo.osc3.yType, "vt4.y", "vt0.w")+
				"mul vt4.x, vt4.x, vc1.w \n"+
				"mul vt4.y, vt4.y, vc1.w \n"+
				
				//add all oscillators together
				
				"add vt5.x, vt1.x, vt2.x \n"+ 
				"add vt5.y, vt1.y, vt2.y \n"+
				
				"add vt0.x, vt5.x, vt3.x \n"+ // start reusing temp register
				"add vt0.y, vt5.y, vt3.y \n"+
				
				"add vt6.x, vt0.x, vt4.x \n"+ 
				"add vt6.y, vt0.y, vt4.y \n"+
				
				"add op.x, vt6.x, va0.x \n"+  // add to the starting vertex positions (center)
				
				
				"add vt0.y, vt6.y, va0.y \n"+
				"mul op.y, vt0.y, vc2.x \n"+
				
				
				// vt7 reserved for trig calculations
				
//				"mov op.x, vt7.x \n"+
//				"mov op.y, vt7.y \n"+
				"mov op.z, va0.z \n"+
				"mov op.w, va0.w \n"+
//				"mov op, va0 \n"+
//				"m44 op, va0, vc10\n" + // pos to clipspace
				
				"mov v0, va1" // copy uv
			);
			
			fragmentShaderAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				//"tex ft1, v0, fs0 <2d,nearest,nomip>\n" +
				"mov oc, v0"
				//				"mov oc.r, v0.r \n"+
				//				"mov oc.g, v0.g \n"+
				//				"mov oc.b, v0.b \n"+
				//				"mov oc.a, v0.a"
			);
			
			program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function trig(trigFunction:int, tReg:String, sReg:String):String
		{
			var code:String;
			
			// vt7 reserved for trig calculations
			switch(trigFunction)
			{
				case 0:
					code = "mov " + tReg + ", vc2.x \n";
					break;
				
				case 1:
					code = "sin " + tReg + ", " + sReg + " \n";
					break;
				
				case 2 :
					code = "cos " + tReg + ", " + sReg + " \n";
					break;
				
				case 3 : 
					code = 
					"sin vt7.x, " + sReg + " \n"+
					"cos vt7.y, " + sReg + " \n"+
					"div " + tReg + "vt7.x, vt7.y \n";
					break;
				
				case 4 : 
					code = 
					"sin vt7.x, " + sReg + " \n"+
					"rcp " + tReg + ", vt7.x \n";
					break;
				
				case 5 : 
					code = 
					"frc vt7.x, " + sReg + " \n"+
					"sub vt7.y, vt7.x, vc2.z \n"+
					"abs vt7.z, vt7.y \n"+
					"mul vt7.w, vt7.z, vc2.w \n"+
					"sub " + tReg + "vt7.w, vc2.y \n";
					break;
			}
//			switch(trigFunction)
//			{
//				case 0:
//					code = "sin " + tReg + ", " + sReg + " \n";
//					break;
//				
//				case 1 :
//					code = "cos " + tReg + ", " + sReg + " \n";
//					break;
//				
//				case 2 : 
//					code = 
//						"sin vt7.x, " + sReg + " \n"+
//						"cos vt7.y, " + sReg + " \n"+
//						"div " + tReg + "vt7.x, vt7.y \n";
//					break;
//						
//				case 3 : 
//					code = 
//						"sin vt7.x, " + sReg + " \n"+
//						"rcp " + tReg + ", vt7.x \n";
//					break;
//				
//				case 4 : 
//					code = 
//					"cos vt7.x, " + sReg + " \n"+
//					"rcp " + tReg + ", vt7.x \n";
//					break;
//				
//				case 5 : 
//					code = 
//					"sin vt7.x, " + sReg + " \n"+
//					"cos vt7.y, " + sReg + " \n"+
//					"div " + tReg + "vt7.y, vt7.x \n";
//					break;
//			}
			
			return code;
		}
		
	}
}