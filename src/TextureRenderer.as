package
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	
	public class TextureRenderer
	{
		protected var _context:Context3D;
		
		public var input:Texture;
		public var output:Texture;
		
		public function TextureRenderer(renderContext:Context3D)
		{
			trace("SET CONTEXT");
			_context = renderContext;
		}
		
		public function render():void {}
		
	}
}