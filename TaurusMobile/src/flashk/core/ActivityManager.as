package flashk.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;

	public class ActivityManager
	{
		private var _map:Object;
		protected var _weakKeys:Boolean=false;
		private var _application:DisplayObjectContainer;
		public function ActivityManager()
		{
			_map = new Object();
		}

		public function get application():DisplayObjectContainer
		{
			return _application;
		}

		static public function get instance():ActivityManager
		{
			return Singleton.getInstanceOrCreate(ActivityManager) as ActivityManager;
		}
		public function register(application:DisplayObjectContainer):void
		{
			_application = application;
		}
		public function addChild(child:DisplayObject):void
		{
			_application.addChild(child);
			if(_application.numChildren>1)
			_application.setChildIndex(child,_application.numChildren-1);
		}
		/**
		 * 
		 * 分发多种事件
		 * 
		 */		
		public function dispatchEvent(type:*):void
		{
			var target:Dictionary = _map[type];
			if(target != null)
			{
				for each(var handle:Function in target)
				{
					handle();
				}
			}
		}
		public function dispatchEventParams(type:*,... args):void
		{
			var target:Dictionary = _map[type];
			if(target != null)
			{
				for each(var handle:Function in target)
				{
					handle.apply(null,args);
				}
			}
		}
		public function dispatchEventArgs(... args):void
		{
			var target:Dictionary = _map[args[0]];
			if(target != null)
			{
				for each(var handle:Function in target)
				{
					handle.apply(null,args);
				}
			}
		}
		public function dispatchEventObject(ob:Object):void 
		{
			var target:Dictionary = _map[ob.type];
			if(target != null)
			{
				for each(var handle:Function in target)
				{
					handle(ob);
				}
			}
		}
		/**
		 * 是否存在事件
		 * @param type
		 * @return 
		 * 
		 */		
		public function hasEventListener(type:*):Boolean
		{
			return _map[type] != null;
		}
		/**
		 * 添加事件 
		 * @param type
		 * @param handle
		 * 
		 */		
		public function addEventListener(type:*,handle:Function):void
		{
			var target:Dictionary = _map[type];
			if(target == null)
			{
				target = new Dictionary(_weakKeys);
			}
			target[handle] = handle;
			_map[type] = target;
		}
		/**
		 * 移除事件 
		 * @param type
		 * @param handle
		 * 
		 */		
		public function removeEventListener(type:*=null,handle:Function=null):void
		{
			if(type==null)
			{
				for(var type1:* in _map)
				{
					for each(var hand1:Function in _map[type1])
					{
						delete _map[type1][hand1];
					}
					delete _map[type1];
				}
			}else{
				var target:Dictionary = _map[type];
				if(target != null)
				{
					if(handle == null)
					{
						for each(var hand2:Function in target)
						{
							delete target[hand2];
						}
						delete _map[type];
					}else{
						delete target[handle];
					}
				}else{
					var old:Function = _map[type];
					if (old != null)
					{
						if (handle == null || old == handle)
						{
							delete _map[type];
						}
					}
				}
			}
		}
	}
}