package flashk.core
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import flashk.controls.Button;
	import flashk.display.IBase;
	import flashk.display.UIBase;
	import flashk.utils.ClassFactory;
	import flashk.utils.ReflectUtil;
	import flashk.utils.SearchUtil;

	/**
	 * 帮助快速创建界面的辅助类
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-20 下午6:21:45
	 * */     
	public final class UIBuilder
	{
		/**
		 * 自动构建UI组件。会根据target的公开属性来自动查询Skin内的同名元件并转换。
		 * 
		 * @param target	目标
		 * @param params	规定需要转换的对象的实际类型，键为属性名，值为属性类型（可以使用ClassFactory），将值设为空则不做任何限制。
		 * @param limitIn	是否限制只转换parms属性规定的对象
		 */
		static public function buildAll(target:UIBase,params:Object=null,limitIn:Boolean=false):void
		{
			var skin:DisplayObject = target.content;
			var children:Array = SearchUtil.findChildrenByClass(skin,DisplayObject);
			var types:Object = ReflectUtil.getPropertyTypeList(target,true);
			
			for (var i:int = 0;i < children.length;i++)
			{
				var obj:DisplayObject = children[i] as DisplayObject;
				var name:String = obj.name;
				if (types[name])
				{
					var ref:ClassFactory;
					if (params)//进行类型约定
					{
						if (params[name])
						{
							if (params[name] is Class)
								ref = new ClassFactory(params[name] as Class);
							else if (params[name] is ClassFactory)
								ref = params[name] as ClassFactory;
						}
						else if (!limitIn)
							ref = new ClassFactory(types[name] as Class);
					}
					else
						ref = new ClassFactory(types[name] as Class)
					
					
					if (ref)
					{
						if (!ref.params)
							ref.params = [];
						
						var displayObj:DisplayObject;
						try //尝试生成GBase对象
						{
							ref.params[0] = obj;	
							displayObj = ref.newInstance();//创建
							if (displayObj is IBase)
								(displayObj as IBase).owner = target;
						}
						catch (e:ArgumentError)
						{
							//否则直接使用皮肤	
							displayObj = obj;
						}
						
						target[name] = displayObj;
						delete types[name];//删除已完成生成的属性
					}
				}
			}
		}
		
		/**
		 * 单独构建一个UI组件
		 *  
		 * @param target	目标
		 * @param name	名称
		 * @param param	重定义参数，如果是ClassFactory则是重定义类型，如果是Object则设定初始值，如果是Array则设定构造方法参数
		 * 这些参数有关Skin的部分将会被忽略，而以找到的Skin为准
		 * 
		 */
		public static function build(target:UIBase, name:String, param:*=null):DisplayObject
		{
			var skin:DisplayObject = SearchUtil.findChildByProperty(target.content,"name",name);
			var cls:ClassFactory = new ClassFactory(ReflectUtil.getTypeByProperty(target,name));
			
			if (param is Class)
				cls = new ClassFactory(param as Class);
			else if (param is ClassFactory)
				cls = param as ClassFactory;
			else if (param is Array)
				cls.params = (param as Array).concat();
			else if (param)
				cls.properties = param;
			
			if (skin)
			{
				if (cls.params)
					cls.params[0] = skin;
				else 
					cls.params = [skin];
			}
			
			var displayObj:UIBase = cls.newInstance();//创建
			displayObj.owner = target;
			
			return displayObj; 
		}
		
		/**
		 * 销毁子对象
		 * @param target
		 * @param all	是否销毁不在属性值里的对象
		 */
		public static function destory(target:UIBase,all:Boolean = false):void
		{
			var skin:DisplayObject = target.content;
			var children:Array = SearchUtil.findChildrenByClass(skin,IBase);
			var types:Object = ReflectUtil.getPropertyTypeList(target,true);
			
			for (var i:int = children.length - 1;i >= 0;i--)
			{
				var obj:DisplayObject = children[i] as DisplayObject;
				if (obj is IBase)
				{
					var name:String = obj.name;
					if (all || types[name])
						(obj as IBase).destory();
				}
			}
		}
		
		/**
		 * 自动按钮事件 
		 * @param target
		 * @param remove	是否是卸载
		 * 
		 */
		public static function autoBNHandlers(target:DisplayObject,remove:Boolean = false,useWeak:Boolean = false):void
		{
			var types:Object = ReflectUtil.getPropertyTypeList(target,true);
			for (var p:String in types)
			{
				if (target.hasOwnProperty(p) && target.hasOwnProperty(p + "Handler") && target[p + "Handler"] is Function)
				{
					if (target["p"] is Button)
					{
						if (remove)
							(target["p"] as Button).removeEventListener(MouseEvent.CLICK,target[p + "Handler"])
						else
							(target["p"] as Button).addEventListener(MouseEvent.CLICK,target[p + "Handler"],false,0,useWeak)
					}
				}
			}
		}
		
		/**
		 * 根据名字获取Skin
		 *  
		 * @param skin
		 * @param name
		 * @return 
		 * 
		 */
		public static function getSkinByName(skin:DisplayObject,name:String):DisplayObject
		{
			return SearchUtil.findChildByProperty(skin,"name",name);
		}
		
	}
}