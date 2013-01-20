package filters
{
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	
	public class BloomFilter extends TextureRenderer
	{
		private static const MAX_BLUR : int = 6;
		private var _blurX : uint;
		private var _blurY : uint;
		private var _blurData : Vector.<Number>;
		private var _stepX : Number = 1;
		private var _stepY : Number = 1;
		private var _numSamples : uint;
		
//		private var core:CoreRenderer;
		private var vertexbuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		private var blurProgram:Program3D;
		private var brightnessProgram:Program3D;
		private var _threshold:Number;
		private var _brightPassData:Vector.<Number>;
		private var temptexture:Texture;
		private var blendAmmount:Vector.<Number>;
		private var programComposite:Program3D;
		private var _blendMode:String;
		private var _compositeData:Vector.<Number>;
		private var indexBuffer2:IndexBuffer3D;
		private var vertexbuffer2:VertexBuffer3D;
		
		public function BloomFilter(context:Context3D)
		{
//			var input:Texture = core.renderTarget;
//			this.core = core;
			super(context);
			
			_blendMode = "add";
			
			_compositeData = Vector.<Number>([ 1, 0, 0, 0 ]);
			
			var dummyTexture:BitmapData = new BitmapData(AppData.bufferSize, AppData.bufferSize, false,0);
			temptexture = _context.createTexture(AppData.bufferSize, AppData.bufferSize, Context3DTextureFormat.BGRA, true);
			temptexture.uploadFromBitmapData(dummyTexture);
			
			
			blendAmmount = Vector.<Number>([ 1, 0, 0, 0 ]);
			
			_threshold = .95;
			_brightPassData = Vector.<Number>([_threshold, 1/(1-_threshold), 0, 0]);
			
			_blurX = _blurY = 5;
			
			_blurData = Vector.<Number>([0, 0, 0, 1, 0, 0, 0, 0]);
			
			updateBlurData();
			
			var vertices:Vector.<Number> = Vector.<Number>([
				-1,-1,0, 0, 0, // x, y, z, u, v
				-1, 1, 0, 0, 1,
				1, 1, 0, 1, 1,
				1, -1, 0, 1, 0]);
			
			// 4 vertices, of 5 Numbers each
			vertexbuffer = _context.createVertexBuffer(4, 5);
			// offset 0, 4 vertices
			vertexbuffer.uploadFromVector(vertices, 0, 4);
			
			//flipped vertices for odd # of drawing routines
			var vertices2:Vector.<Number> = Vector.<Number>([
				-1,-1,0, 0, 1, // x, y, z, u, v
				-1, 1, 0, 0, 0,
				1, 1, 0, 1, 0,
				1, -1, 0, 1, 1]);
			
			// 4 vertices, of 5 Numbers each
			vertexbuffer2 = _context.createVertexBuffer(4, 5);
			// offset 0, 4 vertices
			vertexbuffer2.uploadFromVector(vertices2, 0, 4);
			
			indexBuffer = _context.createIndexBuffer(6);	
			indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
			
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"mov op, va0\n" + // pos to clipspace
				"mov v0, va1" // copy uv to fragment shader
			);
			var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,blurFragment());
			
			blurProgram = _context.createProgram();
			blurProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			
			var fragmentShaderAssembler3 : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler3.assemble( Context3DProgramType.FRAGMENT,brightnessFragment());
			
			brightnessProgram = _context.createProgram();
			brightnessProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler3.agalcode);
			
			var fragmentShaderAssembler2 : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler2.assemble( Context3DProgramType.FRAGMENT, compositeFragment());
			
			programComposite = _context.createProgram();
			programComposite.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler2.agalcode);
			
		}
		private function brightnessFragment():String
		{
			return 	"tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
				"dp3 ft1.x, ft0.xyz, ft0.xyz	\n" +
				"sqt ft1.x, ft1.x				\n" +
				"sub ft1.y, ft1.x, fc0.x		\n" +
				"mul ft1.y, ft1.y, fc0.y		\n" +
				"sat ft1.y, ft1.y				\n" +
				"mul ft0.xyz, ft0.xyz, ft1.y	\n" +
				"mov oc, ft0					\n";
		}
		
		private function blurFragment() : String
		{
			var code : String;
			
			_numSamples = 0;
			
			code = 	"mov ft0, v0	\n" +
				"sub ft0.y, v0.y, fc0.y\n";
			
			for (var y : Number = 0; y <= _blurY; y += _stepY) {
				if (y > 0) code += "sub ft0.x, v0.x, fc0.x\n";
				for (var x : Number = 0; x <= _blurX; x += _stepX) {
					++_numSamples;
					if (x == 0 && y == 0)
						code += "tex ft1, ft0, fs0 <2d,nearest,clamp>\n";
					else
						code += "tex ft2, ft0, fs0 <2d,nearest,clamp>\n" +
							"add ft1, ft1, ft2 \n";
					
					if (x < _blurX)
						code += "add ft0.x, ft0.x, fc1.x	\n";
				}
				if (y < _blurY) code += "add ft0.y, ft0.y, fc1.y	\n";
			}
			
			code += "mul oc, ft1, fc0.z";
			
			_blurData[2] = 1/_numSamples;
			
			return code;
		}
		
		private function compositeFragment():String
		{
			
			var code : String;
			var op : String;
			code = 	"tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
				"tex ft1, v0, fs1 <2d,linear,clamp>	\n";
				"mul ft1, ft1, fc0.x				\n";
			switch (_blendMode) {
				case "multiply":
					op = "mul";
					break;
				case "add":
					op = "add";
					break;
				case "subtract":
					op = "sub";
					break;
				case "normal":
					// for debugging purposes
					op = "mov";
					break;
				default:
					throw new Error("Unknown blend mode");
			}
			if (op != "mov")
				code += op + " oc, ft0, ft1					\n";
			else
				code += "mov oc, ft0						\n";
			return code;
		}
		
		private function updateBlurData() : void
		{
			// todo: must be normalized using view size ratio
			var invW : Number = 1/AppData.bufferSize;
			var invH : Number = 1/AppData.bufferSize;
			
			if (_blurX > MAX_BLUR) _stepX = _blurX/MAX_BLUR;
			else _stepX = 1;
			
			if (_blurY > MAX_BLUR) _stepY = _blurY/MAX_BLUR;
			else _stepY = 1;
			
			_blurData[0] = _blurX*.5*invW;
			_blurData[1] = _blurY*.5*invH;
			_blurData[4] = _stepX*invW;
			_blurData[5] = _stepY*invH;
		}
		
		override public function render():void
		{
			if(!input) throw new Error( "bloom filter input not set");
			//dont need brightness filter on b+w
			
//			_context.setProgram(brightnessProgram);
//			
//			_context.setRenderToTexture(temptexture);
//			
//			_context.setVertexBufferAt(0, vertexbuffer2, 0, Context3DVertexBufferFormat.FLOAT_3);
//			_context.setVertexBufferAt(1, vertexbuffer2, 3, Context3DVertexBufferFormat.FLOAT_2);
//			
//			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _brightPassData, 1);
//			
//			_context.setTextureAt(0, core.renderTarget);
//			
//			_context.clear(0,0,0,0);
//			
//			_context.drawTriangles(indexBuffer);
//			
//			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
//			_context.setVertexBufferAt(1, null, 3, Context3DVertexBufferFormat.FLOAT_2);
//			_context.setTextureAt(0, null);
//			_context.setTextureAt(1, null);
			
			
			
			_context.setProgram(blurProgram);
			
			_context.setRenderToTexture(temptexture);
			
			_context.setVertexBufferAt(0, vertexbuffer2, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, vertexbuffer2, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _blurData, 2);
			
			_context.setTextureAt(0, input);
			
			_context.clear(0,0,0,0);
			
			_context.drawTriangles(indexBuffer);
			
			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, null, 3, Context3DVertexBufferFormat.FLOAT_2);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			
			
			
			_context.setProgram(programComposite);
			
			if(output)	 _context.setRenderToTexture(output);
			else		 _context.setRenderToBackBuffer();
			
			_context.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _compositeData, 1); 
			
			_context.setTextureAt(0, temptexture);
			
			_context.setTextureAt(1, input);
			
			_context.clear(0,0,0,0);
			
			_context.drawTriangles(indexBuffer);
			
			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, null, 3, Context3DVertexBufferFormat.FLOAT_2);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			}
	}
}