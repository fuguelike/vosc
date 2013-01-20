package filters
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.utils.getTimer;

	public class TrailFilter extends TextureRenderer
	{
		public var temptexture:Texture;
		
		
		private const VERTEX_SHADER:String =
			"m44 op, va0, vc0   \n" + // vertex * clipspace
			"mov v0, va1		\n"; // copy uv
		
		private const FRAGMENT_SHADER:String =
			"mov ft0.xyzw, v0.xy                        \n" + // get interpolated uv coords
			"mul ft1, ft0, fc2.y                        \n" +
			"add ft1, ft1, fc2.x                        \n" +
			"cos ft1.y, ft1.w                           \n" +
			"sin ft1.x, ft1.z                           \n" +
			"mul ft1.xy, ft1.xy, fc2.zw                 \n" +
			"add ft0, ft0, ft1                          \n" +
			"tex ft0, ft0, fs0 <2d,clamp,linear,nomip>  \n" + // sample texture
			"mul ft0, ft0, fc0                          \n" + // mult with colorMultiplier
			"add ft0, ft0, fc1                          \n" + // mult with colorOffset
			"mov oc, ft0                                \n";
		
		private var programCopy:Program3D;
		private var programComposite:Program3D;
		private var vertexbuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		
		private var source:Texture;
		private var core:CoreRenderer;
		
		private var colorTransform:ColorTransform = new ColorTransform(1,1,1,1,1,1);
		private var blendAmmount:Vector.<Number>;
		private var compositeTexture:Texture;
		private var inputTexture:Texture;
		
		public function TrailFilter(context:Context3D)
		{
			super(context);
			
//			var bitmap:Bitmap = new TextureBitmap();
//			temptexture = context.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height, Context3DTextureFormat.BGRA, false);
//			temptexture.uploadFromBitmapData(bitmap.bitmapData);
			var dummyTexture:BitmapData = new BitmapData(AppData.bufferSize, AppData.bufferSize, false,0);
			temptexture = _context.createTexture(AppData.bufferSize, AppData.bufferSize, Context3DTextureFormat.BGRA, true);
			temptexture.uploadFromBitmapData(dummyTexture);
			
			
			compositeTexture = _context.createTexture(AppData.bufferSize, AppData.bufferSize, Context3DTextureFormat.BGRA, true);
			
//			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
//			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);
//			
//			var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
//			colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
			
			blendAmmount = Vector.<Number>([ .5, 0, 0, 0 ]);
			
			var vertices:Vector.<Number> = Vector.<Number>([
				-1,-1,0, 0, 0, // x, y, z, u, v
				-1, 1, 0, 0, 1,
				1, 1, 0, 1, 1,
				1, -1, 0, 1, 0]);
			
			// 4 vertices, of 5 Numbers each
			vertexbuffer = _context.createVertexBuffer(4, 5);
			// offset 0, 4 vertices
			vertexbuffer.uploadFromVector(vertices, 0, 4);
			
			// total of 6 indices. 2 triangles by 3 vertices each
			indexBuffer = _context.createIndexBuffer(6);			
			
			// offset 0, count 6
			indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
			
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"mov op, va0\n" + // pos to clipspace
				"mov v0, va1" // copy uv to fragment shader
			);
			var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				
				"tex oc, v0, fs0 <2d,repeat,linear>\n"
			);
			
			programCopy = _context.createProgram();
			programCopy.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			
			var fragmentShaderAssembler2 : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler2.assemble( Context3DProgramType.FRAGMENT,
				
				"tex ft0, v0, fs0 <2d,repeat,nearest>	\n" +
				"tex ft1, v0, fs1 <2d,repeat,nearest>	\n" +
				"sub ft1, ft1, ft0				\n" +
				"mul ft1, ft1, fc0.x			\n" +
				"add oc, ft1, ft0				\n"
			);
			 
			
			programComposite = _context.createProgram();
			programComposite.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler2.agalcode);
		}
		
		
		override public function render():void
		{	
			if(!input) throw new Error( "trail filter input not set");
			
			_context.setProgram(programComposite);
			
			_context.setRenderToTexture(compositeTexture);
			
			_context.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, blendAmmount); 
			
			_context.setTextureAt(0, input);
			
			_context.setTextureAt(1, temptexture);
			
			_context.clear(0,0,0,0);
			
			_context.drawTriangles(indexBuffer);
			
			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, null, 3, Context3DVertexBufferFormat.FLOAT_2);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			
			// store composite in temp for next frame
			_context.setProgram(programCopy);
			
			_context.setRenderToTexture(temptexture);
			
			_context.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			_context.setTextureAt(0, compositeTexture);
			
			_context.clear(0,0,0,0);
			
			_context.drawTriangles(indexBuffer);
			
			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, null, 3, Context3DVertexBufferFormat.FLOAT_2);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			
			//copy the composite for rendering
			_context.setProgram(programCopy);
			
			if(output)	 _context.setRenderToTexture(output);
			else		 _context.setRenderToBackBuffer();
			
			_context.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			_context.setTextureAt(0, compositeTexture);
			
			_context.clear(0,0,0,0);
			
			_context.drawTriangles(indexBuffer);
			
			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, null, 3, Context3DVertexBufferFormat.FLOAT_2);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			
			////////////////////////////////////////////////
			
//			_context.setProgram(programCopy);
//			
//			_context.setRenderToBackBuffer();
//			// vertex position to attribute register 0 va0
//			_context.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
//			// uv coordinates to attribute register 1 va1
//			_context.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
//			// assign texture to texture sampler 0 fs0
//			_context.setTextureAt(0, core.renderTarget);	
//			
//			
//			_context.clear(0,0,0,0);
//			
//			_context.drawTriangles(indexBuffer);
//			
//			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
//			_context.setVertexBufferAt(1, null, 3, Context3DVertexBufferFormat.FLOAT_2);
//			_context.setTextureAt(0, null);
			
			
		}
		
		
	}
}