package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flashk.core.ActivityManager;
	import flashk.core.RootManager;
	import flashk.core.UIBuilder;
	import flashk.core.UIConst;
	import flashk.display.UIBase;
	import flashk.events.ActionEvent;
	
	
	[Event(name="close",type="flash.events.Event")]

	/**
	 * 窗口
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2015-6-6 下午3:45:06
	 * */     
	public class Window extends Panel
	{
		public var closeButton:Button;
		public var closeHandler:Function;
		public var showHandler:Function;
		private var _prev:Window;
		/**
		 * 显示模式 
		 */		
		public var showMode:String = "switch";
		public var type:*;
		/**
		 * 显示切面模式
		 * 左边:负数 ;右边:正数
		 */		
		public var switchWidth:int=0;
		/**
		 * 布局模式 上中下 
		 */		
		public var layoutMode:String = "";
		/**
		 * 是否激活居中显示
		 */
		public var enabledCenter:Boolean = true;
		/**
		 * 显示  区域
		 */		
		public var view:UIBase;
		
		private var backgroundWindow:Sprite;
		public var fields:Object = {closeButton:"closeButton",viewField:"view"};
		
		public function Window(skin:*=null, replace:Boolean=true,fields:Object = null)
		{
			if (fields)
				this.fields = fields;
			super(skin, replace);
		}
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			UIBuilder.buildAll(this);
			
			if(closeButton!=null)
			{
				closeButton.action="close";
				closeButton.addEventListener(ActionEvent.ACTION,closeButtonClickHandler);
			}
			if(layoutMode==UIConst.BOTTOM)
			{
				this.y = int(RootManager.showHeight-this.width);
			}else if(layoutMode==UIConst.CENTER)
			{
				this.y = int((RootManager.showHeight-this.width)/2);
			}
		}
		
		public override function setBackgroundSkin(skin:*):void
		{
			if (backgroundWindow)
			{
				backgroundWindow.removeEventListener(MouseEvent.CLICK,onBackground);
				$removeChild(backgroundWindow);
			}
			backgroundWindow = new Sprite();
			backgroundWindow.graphics.beginFill(0,0);
			backgroundWindow.graphics.drawRect(-switchWidth,0,RootManager.showWidth,RootManager.showHeight);
			backgroundWindow.addEventListener(MouseEvent.CLICK,onBackground);
			$addChildAt(backgroundWindow,0);
			
		}
		private function onBackground(evt:MouseEvent):void
		{
			if(_prev!=null)
			{
				send(_prev.type);
			}
		}
		protected function closeButtonClickHandler(event:ActionEvent):void
		{
			if(this.closeHandler==null)
				dispatchEvent(new Event(Event.CLOSE));
			else
				this.closeHandler();
			close();
		}
		public function close():void
		{
			if(this.parent!=null)
			{
				this.parent.removeChild(this);
			}
			if(_prev!=null)
			{
				_prev.x = 0;
				_prev.show();
				_prev = null;
			}
		}
		public function send(type:*,... args):void
		{
			ActivityManager.instance.dispatchEventArgs.apply(null,[type,this].concat(args));
			if(showMode!=UIConst.EMPTY)
			{
				closeButtonClickHandler(null);
			}
		}
		public function register(type:*):void
		{
			this.type = type;
			ActivityManager.instance.addEventListener(type,funshow);
		}
		protected function funshow(... args):void
		{
			args.shift();
			_prev = args.shift();
			if(showMode==UIConst.LEFT)
			{
				_prev.x = _prev.width+switchWidth;
				this.x = switchWidth;
			}else if(showMode==UIConst.RIGHT)
			{
				_prev.x = -_prev.width+switchWidth;
				this.x = switchWidth;
			}
			show();
			if(showHandler!=null)
			{
				showHandler.apply(null,args);
			}
		}
		public function show():void
		{
			if(this.parent==null)
			{
				ActivityManager.instance.addChild(this);
			}
		}
		/**
		 * 添加事件 
		 * @param type
		 * @param handle
		 * 
		 */		
		public function addEventTypeListener(type:*,handle:Function):void
		{
			ActivityManager.instance.addEventListener(type,handle);
		}
		/**
		 * 
		 * 分发多种事件
		 * 
		 */		
		public function dispatchEventType(type:*):void
		{
			ActivityManager.instance.dispatchEvent(type);
		}
		public function dispatchEventArgs(type:*,... args):void
		{
			ActivityManager.instance.dispatchEventArgs.apply(null,[type].concat(args));
		}
		public function dispatchEventObject(ob:Object):void 
		{
			ActivityManager.instance.dispatchEventObject(ob);
		}
		public override function destory() : void
		{
			if (destoryed)
				return;
			if(closeButton!=null)
			{
				closeButton.removeEventListener(ActionEvent.ACTION,closeButtonClickHandler);
			}
			UIBuilder.destory(this);
			
			super.destory();
		}
	}
}