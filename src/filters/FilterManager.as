package filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.events.Event;
	
	import model.Data;

	public class FilterManager
	{
		
		private var _filters:Vector.<TextureRenderer>;
		private var _context:Context3D;
		private var data:Data;
		
		private var _bloomFilter:BloomFilter;
		private var _trailFilter:TrailFilter;
		
		public function FilterManager(context:Context3D, source:TextureRenderer)
		{
			_context = context;
			
			_filters = new Vector.<TextureRenderer>;
			
			_bloomFilter = new BloomFilter(_context);
			_trailFilter = new TrailFilter(_context);
			
			
			data = Data.getInstance();
			data.addEventListener(Data.UPDATE_FILTER, onFiltersChange);
			
			add(source);
		}
		
		protected function onFiltersChange(event:Event):void
		{
			data.getBloomFilterEnabled() ? add(_bloomFilter) : remove(_bloomFilter);
			
			data.getTrailFilterEnabled() ? add(_trailFilter) : remove(_trailFilter);
		}
		
		public function add(filter:TextureRenderer):void
		{
			if(_filters.indexOf(filter) == -1)
				_filters.push(filter);
			
			updateChain();
		}
		
		public function remove(filter:TextureRenderer):void
		{
			if(_filters.indexOf(filter) != -1)
				_filters.splice(_filters.indexOf(filter),1);
			
			updateChain();
		}
		
		public function updateChain():void
		{
			for(var i:int=1; i<_filters.length; i++)
			{
				_filters[i].input = _filters[i-1].output = _context.createTexture(AppData.bufferSize, AppData.bufferSize, Context3DTextureFormat.BGRA, true);
			}
			
			_filters[_filters.length-1].output = null;
			trace("update chain");	
		}
		
		public function render():void
		{
			for(var i:int=1; i<_filters.length; i++)
			{
				_filters[i].render();
			}
		}
		
		public function dispose():void
		{
			// TODO Auto Generated method stub
			_context = null;
		}
	}
}