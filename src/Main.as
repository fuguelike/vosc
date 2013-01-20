package
{
	import com.adobe.utils.*;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.*;
	import flash.display3D.textures.Texture;
	import flash.events.*;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import model.Data;
	import model.OscData;
	import model.OscVO;
	import model.SaveLoadService;
	
	import net.hires.debug.Stats;
	
	import ui.DynamicTF;
	
	import view.ColorPickerPanel;
	import view.OscPanel;
	import view.ResolutionPanel;
	import view.SaveLoadPanel;
	import view.VoscUI;
	
	
	public class Main extends Sprite
	{	
		protected var data:Data;
		
		protected var context3D:Context3D;
		protected var stage3D:Stage3D;
		
		protected var coreRenderer:CoreRenderer;
//		protected var filterManager:FilterManager;
		
		[Embed(source = "../assets/title_small.png")]
		public static const Background:Class;
		
		protected var startupBitmap:Bitmap;
		protected var startupBtn:Sprite;
		
		protected var _status:DynamicTF;
	 
		protected var _startupActions:int = 0;
		
		protected var vui:VoscUI;
		protected var _paused:Boolean = true;
		
		public function Main()
		{ 
		  	stage3D = stage.stage3Ds[0];
			
			stage3D.addEventListener( Event.CONTEXT3D_CREATE, init3D );
			stage3D.requestContext3D();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			
			
			data = Data.getInstance();
			if(stage.fullScreenWidth > stage.fullScreenHeight)
			{
				AppData.bufferSize = stage.fullScreenWidth;
				data.stageW = stage.fullScreenWidth;
				data.stageH = stage.fullScreenHeight;
			}
			else
			{
				AppData.bufferSize = stage.fullScreenHeight;
				data.stageW = stage.fullScreenHeight;
				data.stageH = stage.fullScreenWidth;
			}
			
			startupBitmap = new Background();
			startupBitmap.smoothing = true;
			
			
			vui = new VoscUI();
			
			var oscDatas:Vector.<OscData> = new Vector.<OscData>;
			
			for(var i:int=0; i<4; i++)
			{
				var moduleData:OscData = new OscData(new OscVO());
				oscDatas.push(moduleData);
				
				var panel:OscPanel = new OscPanel(moduleData);
				panel.setTitle(i+1);
				panel.init();
				vui.addItem(panel,"OSC "+i.toString());
			}
			
			data.init(oscDatas);
			
			vui.addItem(new ColorPickerPanel(data.fgColors, data.bgColors),"COLOR");
			
			vui.addItem(new ResolutionPanel(),"RES");
			
			var sl:SaveLoadService = new SaveLoadService();
			vui.addItem(new SaveLoadPanel(sl),"PATCH");
			
			vui.scaleX = vui.scaleY = AppData.uiScale;
			
			_status = new DynamicTF();
			_status.field_txt.text = "LOADING...";
			_status.mouseEnabled = false;
			_status.mouseChildren = false;
			addChild(_status);
			
			showStartup();
			onResize(null);
			
			sl.init();
			
			setTimeout(registerStartupAction, 2000);
			
//			var stats:Stats = new Stats();
//			stats.x = 480;
//			addChild(stats);
		}
		
		protected function onResize(event:Event):void
		{
			startupBitmap.x = Math.round(stage.stageWidth/2 - startupBitmap.width/2);
			startupBitmap.y = Math.round(stage.stageHeight/2 - startupBitmap.height/2);
			
			_status.x = Math.round(stage.stageWidth/2);
			_status.y = Math.round(100+ stage.stageHeight/2);
			
		}		
		
		protected function init3D(e:Event):void
		{
			trace("INIT3D");
			registerStartupAction();
			if(context3D) onContextLoss(null);
			context3D = stage.stage3Ds[0].context3D;
			
//			if(context3D.driverInfo.toLowerCase().indexOf("software") != -1)
//			{
//				AppData.DEFAULT_RESOLUTION = 2;
//				Data.getInstance().
//			}
			
			context3D.enableErrorChecking = true;
			context3D.configureBackBuffer(data.stageW, data.stageH, 2, false);
			context3D.addEventListener(Event.DEACTIVATE, onContextLoss);
			coreRenderer = new CoreRenderer(context3D);
//			filterManager = new FilterManager(context3D, coreRenderer);
			addEventListener(Event.ENTER_FRAME, onRender);
			
			
			stage3D.addEventListener(Event.DEACTIVATE, onStageDeactivate);
			stage3D.addEventListener(Event.ACTIVATE, onStageActivate);
		}
		
		
		protected function registerStartupAction():void
		{
			_startupActions++;
			if(_startupActions < 2) return;
			startupComplete();
		}
		
		protected function startupComplete():void
		{
			//for override
		}
		
		protected function exitStartup():void
		{
			addChildAt(vui,0);
		}
		
		protected function showStartup():void
		{
			
		}
		
		protected function onRender(e:Event):void
		{
			if ( _paused ) return;
			
//			trace("RENDER");
			
			data.updateTime();
			coreRenderer.render();
//			filterManager.render();
			context3D.present();
		}
		
		protected function onContextLoss(event:Event):void
		{
			trace("Context Loss");
			removeEventListener(Event.ENTER_FRAME, onRender);
			coreRenderer.dispose();
			
//			context3D = null;
//			
//			coreRenderer = null;
		}
		
		
		protected function onStageActivate(event:Event):void
		{
			trace("activate");
			if(context3D) onContextLoss(null);
			context3D = stage.stage3Ds[0].context3D;
			
//			if(context3D.driverInfo.toLowerCase().indexOf("software") != -1)
//			{
//				AppData.DEFAULT_RESOLUTION = 2;
//				Data.getInstance().
//			}
			
			context3D.enableErrorChecking = true;
			context3D.configureBackBuffer(data.stageW, data.stageH, 2, false);
			context3D.addEventListener(Event.DEACTIVATE, onContextLoss);
			coreRenderer = new CoreRenderer(context3D);
//			filterManager = new FilterManager(context3D, coreRenderer);
			addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		protected function onStageDeactivate(event:Event):void
		{
			trace("deactivate");
		}
		
		protected function simulateLoss():void
		{
			trace("SIMULATE LOSS");
			context3D.dispose();
			onContextLoss(null);
		}
	}
}