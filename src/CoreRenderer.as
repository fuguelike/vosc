 package
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	
	import model.Data;

	public class CoreRenderer extends TextureRenderer
	{
		public var renderTarget:Texture;
		
		private var data:Data;
		private var nQuads:int;
		private var vertexbuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		private var shader:Shader;
		private var program:Program3D;
		private var vertexbuffer2:VertexBuffer3D;
		
		private var vbos:Vector.<VertexBuffer3D>;
		
		private var nVBOs:int;
		
		private const quadsPerBuffer:int = 16000;
		
		private var bufferIncrement:Number = Math.PI*2/16000;
		
		private var _id:Number;
		
		public function CoreRenderer(context:Context3D)
		{
			super(context);
			_id = Math.random();
//			output = _context.createTexture(AppData.bufferSize, AppData.bufferSize, Context3DTextureFormat.BGRA, true);
			
			data = Data.getInstance();
			data.addEventListener(Data.UPDATE_SHADER, onShaderDataUpdate);
			data.addEventListener(Data.UPDATE_VERTEX, onVertexDataUpdate);
			
//			trace("NVBOS: "+nVBOs);
			
			setVBOs();
			
			program = _context.createProgram();
			
			shader = new Shader();
			shader.uploadTo(program);
		}
		
		
		
		override public function render():void
		{
			// render to texture for post-processing
//			trace("CORE BEGIN"+_id);
			
			_context.setVertexBufferAt(0, vbos[0], 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, vbos[0], 3, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(2, vbos[0], 6, Context3DVertexBufferFormat.FLOAT_1);
			
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, data.loopNumVec);
			
			var radiusVec:Vector.<Number> = Vector.<Number>(
				[data.oscDatas[0].radius, data.oscDatas[1].radius, data.oscDatas[2].radius, data.oscDatas[3].radius]
			);
			
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1, radiusVec);
			
			var constVec:Vector.<Number> = Vector.<Number>([data.stageW/data.stageH,1,.5,4]);
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 2, constVec);
			
//			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([data.bgR, data.bgG, data.bgB,1]));
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([data.fgR, data.fgG, data.fgB,1]));
			
			_context.setProgram(program);
			
			if(output)	
			{
				_context.setRenderToTexture(output);
			}
			else _context.setRenderToBackBuffer();
			
			_context.clear(data.bgR, data.bgG, data.bgB, 1);
			_context.drawTriangles(indexBuffer);
			
			if(vbos.length > 1)
			{
				for (var i:int=1; i<vbos.length; i++)
				{
					_context.setVertexBufferAt(0, vbos[i], 0, Context3DVertexBufferFormat.FLOAT_3);
					_context.setVertexBufferAt(1, vbos[i], 3, Context3DVertexBufferFormat.FLOAT_3);
					_context.setVertexBufferAt(2, vbos[i], 6, Context3DVertexBufferFormat.FLOAT_1);
					
					_context.drawTriangles(indexBuffer);
				}
			}
			
			_context.setVertexBufferAt(0, null);
			_context.setVertexBufferAt(1, null);
			_context.setVertexBufferAt(2, null);
			//trace("CORE END");
		}
		
		protected function onVertexDataUpdate(event:Event):void
		{
			trace("VERTEX UPDATE");
			setVBOs(data.fgR, data.fgG, data.fgB);
		}
		
		protected function onShaderDataUpdate(event:Event):void
		{
			trace("SHADER UPDATE");
			program = _context.createProgram();
			shader.uploadTo(program);
		}
		
		private function setVBOs(r:Number=1, g:Number=1, b:Number=1):void
		{
			nQuads = data.numPoints;
			nVBOs = Math.ceil(nQuads/quadsPerBuffer);
			vbos = Vector.<VertexBuffer3D>([]);
//			quadsPerBuffer = (nQuads < 16000) ? nQuads : 16000;
//			trace("SET VBOS: "+nVBOs);
			
			
			var size:Number = 1024 / AppData.bufferSize * .002;
//			if(nVBOs < 3) size *= 1.2;
			trace("NVBOs: "+nVBOs);
			
			for(var j:int=0; j< nVBOs; j++)
			{
				var vertices:Vector.<Number> = new Vector.<Number>;
				var offset:Number = bufferIncrement*j/nVBOs;
				var totalDistribution:Number;
				
				for (var i:int=0; i<quadsPerBuffer; i++)
				{ 
					totalDistribution = i*bufferIncrement + offset;
//					trace(totalDistribution);
					vertices.push(
						0,		 0, 0,        r, g, b, totalDistribution, // x, y, z, r, g, b, position from 0 to 1
						size,	 0, 0,        r, g, b, totalDistribution,
						size,	 -size, 0,    r, g, b, totalDistribution,
						0,		 -size, 0,    r, g, b, totalDistribution
					);
				}
				// 4 vertices, of 6 Numbers each
				var vb:VertexBuffer3D = _context.createVertexBuffer(4*quadsPerBuffer, 7);
				// offset 0, 4 verticestyyryut
				vb.uploadFromVector(vertices, 0, 4*quadsPerBuffer);
				
				vbos.push(vb);
				
				indexBuffer = _context.createIndexBuffer(6*quadsPerBuffer);			
				indexBuffer.uploadFromVector(createIBO2(),0,6*quadsPerBuffer);
			}
		}
		
		private function createIBO2():Vector.<uint>
		{
			var ibo:Vector.<uint> = new Vector.<uint>;
			
			for (var i:int=0; i<quadsPerBuffer; i++)
			{
				ibo.push(0+4*i,1+4*i,2+4*i,2+4*i,3+4*i,0+4*i);
			}
			
			return ibo;
		}
		
		public function dispose():void
		{
			// TODO Auto Generated method stub
//			trace("DISPOSE"+_id);
			data.removeEventListener(Data.UPDATE_SHADER, onShaderDataUpdate);
			data.removeEventListener(Data.UPDATE_VERTEX, onVertexDataUpdate);
			program = null;
			_context = null;
		}
	}
}