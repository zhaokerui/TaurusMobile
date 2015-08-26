package flashk.core
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	
	/**
	 * 舞台对象相关扩展
	 * 
	 * @author kerry
	 * 
	 */	
	public final class RootManager
	{
		private static var _root:Sprite;
		
		/**
		 * 普通模式
		 */
		public static const MODE_NORMAL:int = 0;
		/**
		 * 无缩放模式
		 */
		public static const MODE_NOSCALE:int = 1;
		/**
		 * 指定当前的操作系统
		 */		
		public static var os:String;
		public static var stageWidth:int;
		public static var stageHeight:int;
		public static var appWidth:int = 640;
		public static var appHeight:int = 960;
		public static var showHeight:int = 960;
		public static var showWidth:int = 640;
		public static var scale:Number = 1.0;
		public static var isIOS:Boolean = false;
		
		/**
		 * 场景对象 
		 * @return 
		 * 
		 */
		public static function get root():Sprite
		{
			if (!_root)
				throw new Error("请先使用RootManager.register()方法注册舞台");
			return _root;
		}
		
		public static function set root(v:Sprite):void
		{
			_root = v;
		}
		
		/**
		 * 舞台对象 
		 * @return 
		 * 
		 */
		public static function get stage():Stage
		{
			return root.stage;
		}
		
		/**
		 * 是否已经初始化 
		 * @return 
		 * 
		 */
		public static function get initialized():Boolean
		{
			return _root!=null;
		}
		
		/**
		 * 注册对象
		 * 
		 * @param root	舞台
		 * @param mode	模式
		 * @param menuMode	菜单模式
		 * 
		 */
		public static function register(root:Sprite,mode:int = 1,screenMode:int = 1):void
		{
			_root = root;
			
			setMode(mode);
			
			setScreen(screenMode);
			
			Tick.frameRate = stage.frameRate;
		}
		
		
		/**
		 * 设置缩放模式 
		 * @param mode
		 * 
		 */
		public static function setMode(mode:int):void
		{
			switch (mode)
			{
				case MODE_NORMAL:
					stage.scaleMode = StageScaleMode.EXACT_FIT;
					stage.align = StageAlign.TOP;
					break;
				case MODE_NOSCALE:
					stage.scaleMode = StageScaleMode.NO_SCALE;
					stage.align = StageAlign.TOP_LEFT;
					break;
			}
		}
		/**
		 * 设置屏幕
		 * 
		 */		
		public static function setScreen(mode:int):void
		{
			os = Capabilities.os.toLowerCase();
			if(os.indexOf("windows") !=-1 || os.indexOf("mac") != -1)
			{
				stageWidth = stage.stageWidth;
				stageHeight = stage.stageHeight;
			}else{
				if(os.indexOf("ip") != -1 )
				{
					stageWidth = stage.fullScreenWidth;
					stageHeight = stage.fullScreenHeight -40;
				}else{
					stageWidth = stage.stageWidth;
					stageHeight = stage.stageHeight;
				}
			}
			scale = Math.min(stageWidth/appWidth,stageHeight/appHeight);
			if(mode==1){
				scale = stageWidth/appWidth;
			}
			if(os.indexOf("ip") != -1 )
			{
				isIOS = true;
				scale = 1;
				root.y = 40;
			}
			if(os.indexOf("iphone os 6.") != -1){
				root.y = 0;
				stageHeight += 40;
			}
			root.scaleX = root.scaleY = scale;
			showHeight = Math.round(stageHeight/scale+1);
			showWidth = Math.round(stageWidth/scale+1);
		}
		
		
	}
}