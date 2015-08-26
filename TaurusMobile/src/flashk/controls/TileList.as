package flashk.controls
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashk.core.UIConst;
	import flashk.display.IBase;
	import flashk.display.UIBase;
	import flashk.events.ItemClickEvent;
	import flashk.events.RepeatEvent;
	import flashk.utils.ClassFactory;
	
	import taurus.skin.ListBackground;
	
	[Event(name="change",type="flash.events.Event")]
	[Event(name="item_click",type="flashk.events.ItemClickEvent")]
	
	
	
	

	/**
	 * 没有滚动条的List
	 * 
	 * 标签规则：skin直接被当作重复块的skin处理
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-6 下午3:27:28
	 * */     
	public class TileList extends Tile
	{
		public static var defaultSkin:ClassFactory =  new ClassFactory(ListBackground);
		public static var defaultItemRender:ClassFactory = new ClassFactory(Button,{autoSize:"left",autoRefreshLabelField:true},[null,true,true]);
		
		/**
		 * 类型 
		 */
		public var type:String = UIConst.VERTICAL;
		
		/**
		 * 是否自动更新Item的皮肤大小 
		 */
		public var autoReszieItemContent:Boolean = true;
		
		/**
		 * 是否隐藏空对象
		 */
		public var hideNullItem:Boolean = true;
		
		/**
		 * 点击选择
		 */
		public var toggleOnClick:Boolean = true;
		
		private var _columnCount:int = -1;
		
		private var _selectedData:*;
		
		private var itemSkin:ClassFactory;//ItemRender的皮肤
		
		/**
		 * 
		 * @param skin	Render皮肤
		 * @param replace	是否替换
		 * @param type	滚动方向
		 * @param itemRender	Render类
		 * 
		 */
		public function TileList(skin:*=null,replace:Boolean = true, type:String = UIConst.VERTICAL,itemRender:* = null)
		{
			if (itemRender is Class)
				itemRender = new ClassFactory(itemRender);
			
			if (!itemRender)
				itemRender = defaultItemRender;
			
			if (skin)
			{
				if (skin is DisplayObject)
					itemSkin = new ClassFactory(skin["constructor"]);
				else if (skin is Class)
					itemSkin = new ClassFactory(skin);
				else if (skin is ClassFactory)
					itemSkin = skin as ClassFactory
			}
			
			if (!itemSkin)
				itemSkin = defaultSkin;
			
			this.type = type;
			
			if (itemRender.params)
				itemRender.params[0] = itemSkin;
			else
				itemRender.params = [itemSkin];
			
			super(itemRender);
			
			if (skin is DisplayObject && skin.parent)
			{
				var t:DisplayObject = skin;
				var oldIndex:int = t.parent.getChildIndex(t);
				var p:DisplayObjectContainer = t.parent;
				if (p)
				{
					p.removeChild(t);
					p.addChildAt(this,oldIndex);
					this.x = t.x;
					this.y = t.y;
				}
			}
			
			addEventListener(RepeatEvent.ADD_REPEAT_ITEM,addRepeatItemHandler);
			addEventListener(RepeatEvent.REMOVE_REPEAT_ITEM,removeRepeatItemHandler);
			
			addEventListener(MouseEvent.CLICK,clickHandler);
		}
		
		/**
		 * 设置ItemRender
		 * @param v
		 * 
		 */
		public function set itemRender(v:*):void
		{
			if (v is Class)
				v = new ClassFactory(v);
			
			this.ref = v;
			
			if (v.params)
				v.params[0] = itemSkin;
			else
				v.params = [itemSkin];
			
			setContentClass(this.ref);
		}
		
		public function get itemRender():*
		{
			return this.ref;
		}
		
		/**
		 * 获得某个坐标的数据 
		 * @param i
		 * @param j
		 * @return 
		 * 
		 */
		public function getDataAt(i:int,j:int):*
		{
			if (type == UIConst.HORIZONTAL)
				return data[i];
			else if (type == UIConst.VERTICAL)
				return data[j];
			else
				return data[j * columnCount + i];
		}
		
		/**
		 * 获得某个数据的坐标
		 * @param v
		 * @return 
		 * 
		 */
		public function getPointFromData(v:*):Point
		{
			var index:int = data ? data.indexOf(v) : -1;
			if (index == -1)
				return null;
			
			if (type == UIConst.HORIZONTAL)
				return new Point(index,0);
			else if (type == UIConst.VERTICAL)
				return new Point(0,index);
			else
				return new Point(index % columnCount,int(index / columnCount));
		}
		
		/**
		 * 由元素获得数据 
		 * @param item
		 * @return 
		 * 
		 */
		public function getDataFromRender(item:DisplayObject):*
		{
			var i:int = item.x / columnWidth;
			var j:int = item.y / rowHeight;
			return getDataAt(i,j);
		}
		
		/**
		 * 由数据获得元素 
		 * @param v
		 * @return 
		 * 
		 */
		public function getRender(v:*):DisplayObject
		{
			var p:Point = getPointFromData(v);
			return p ? getItemAt(p.x,p.y) : null;
		}
		
		/**
		 * 选择的数据 
		 * @return 
		 * 
		 */
		public function get selectedData():*
		{
			return _selectedData;
		}
		
		public function set selectedData(v:*):void
		{
			var oldSelectedItem:DisplayObject = getRender(_selectedData);
			if (oldSelectedItem && oldSelectedItem is UIBase)
				(oldSelectedItem as UIBase).selected = false;
			
			_selectedData = v;
			
			var item:DisplayObject = selectedItem;
			oldSelectedItem = item;
			
			if (item && item is UIBase)
				(item as UIBase).selected = true;
			
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		/**
		 * 选择的行
		 * @return 
		 * 
		 */
		public function get selectedRow():int
		{
			var selectIndex:int = data ? data.indexOf(_selectedData) : -1;
			
			if (selectIndex != -1)
			{
				if (type == UIConst.HORIZONTAL)
					return 0;
				else if (type == UIConst.VERTICAL)
					return selectIndex;
				else
					return selectIndex / columnCount;
			}
			return -1;
		}
		
		public function set selectedRow(v:int):void
		{
			selectedData = getDataAt(selectedColumn,v);
		}
		
		/**
		 * 选择的列
		 * @return 
		 * 
		 */
		public function get selectedColumn():int
		{
			var selectIndex:int = data ? data.indexOf(_selectedData) : -1;
			
			if (selectIndex != -1)
			{
				if (type == UIConst.HORIZONTAL)
					return selectIndex;
				else if (type == UIConst.VERTICAL)
					return 0;
				else
					return selectIndex % columnCount;
			}
			return -1;
		}
		
		public function set selectedColumn(v:int):void
		{
			selectedData = getDataAt(v,selectedRow);
		}
		
		/**
		 * 选择的元素 
		 * @return 
		 * 
		 */
		public function get selectedItem():DisplayObject
		{
			return getItemAt(selectedColumn,selectedRow);
		}
		
		public function set selectedItem(v:DisplayObject):void
		{
			selectedData = (v as UIBase).data;
		}
		
		/**
		 * 选择的数据项
		 * @return 
		 * 
		 */
		public function get selectedIndex():int
		{
			return data.indexOf(_selectedData);
		}
		
		public function set selectedIndex(v:int):void
		{
			selectedData = data[v];
		}
		
		/**
		 * 元素大小 
		 * @return 
		 * 
		 */
		public override function get contentRect():Rectangle
		{
			var rect:Rectangle = super.contentRect.clone();
			
			if (type == UIConst.HORIZONTAL)
				rect.height = height;
			else if (type == UIConst.VERTICAL)
				rect.width = width;
			
			return rect;
		}
		
		/**
		 * 总列数 
		 * @param v
		 * 
		 */
		public function set columnCount(v:int):void
		{
			_columnCount = v;
		}
		
		public function get columnCount():int
		{
			if (type == UIConst.HORIZONTAL)
				return data ? data.length : 0;
			else if (type == UIConst.VERTICAL)
				return 1;
			else
			{
				if (_columnCount > 0)
					return _columnCount;
				else if (super.width > 0)
					return Math.ceil(super.width / columnWidth);
				else
					return 1;
			}
		}
		
		/**
		 * 总行数 
		 * @return 
		 * 
		 */
		public function get rowCount():int
		{
			if (type == UIConst.HORIZONTAL)
				return 1;
			else if (type == UIConst.VERTICAL)
				return data ? data.length : 0;
			else
				return data ? Math.ceil(data.length / columnCount) : 0;
		}
		
		/**
		 * 组件的宽度 
		 * @return 
		 * 
		 */
		public override function get width() : Number
		{
			return (type != UIConst.VERTICAL) ? columnWidth * columnCount : super.width ? super.width : _contentRect.width;
		}
		
		/**
		 * 组件的高度 
		 * @return 
		 * 
		 */
		public override function get height() : Number
		{
			return (type != UIConst.HORIZONTAL) ? rowHeight * rowCount : super.height ? super.height : _contentRect.height;
		}
		
		/**
		 * 列宽 
		 * @return 
		 * 
		 */
		public function get columnWidth():Number
		{
			return (type == UIConst.VERTICAL) ? width : _contentRect.width;
		}
		
		public function set columnWidth(v:Number):void
		{
			_contentRect.width = v;
		}
		
		/**
		 * 行高
		 * @return 
		 * 
		 */
		public function get rowHeight():Number
		{
			return (type == UIConst.HORIZONTAL) ? height : _contentRect.height;
		}
		
		public function set rowHeight(v:Number):void
		{
			_contentRect.height = v;
		}
		/** @inheritDoc*/
		public override function set data(v:*):void
		{
			super.data = v;
			refresh();
			
		}
		/**
		 * 增加元素事件 
		 * @param event
		 * 
		 */
		protected function addRepeatItemHandler(event:RepeatEvent):void
		{
			var p:Point = event.repeatPos;
			var item:UIBase = event.repeatObj as UIBase;
			item.owner = self;
			
			refreshIndex(p.x,p.y);
			
			if (hideNullItem)
				item.visible = (item.data != null);
		}
		
		/**
		 * 移除元素事件 
		 * @param event
		 * 
		 */
		protected function removeRepeatItemHandler(event:RepeatEvent):void
		{
			var item:UIBase = event.repeatObj as UIBase;
			item.data = null;
			item.selected = false;
		}
		
		/**
		 * 点击事件 
		 * @param event
		 * 
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			if (event.target == this)
				return;
			
			var o:DisplayObject = event.target as DisplayObject;
			while (o && o.parent != this)
				o = o.parent;
			
			if (ref.isClass(o))
			{
				if (toggleOnClick)
					selectedItem = o;
				var e:ItemClickEvent = new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
				e.data = (o as UIBase).data;
				e.relatedObject = o as InteractiveObject;
				dispatchEvent(e);
			}
		}
		
		/**
		 * 刷新某个坐标的元素 
		 * @param i
		 * @param j
		 * @return 
		 * 
		 */
		public function refreshIndex(i:int,j:int):UIBase
		{
			var item:UIBase = getItemAt(i,j);
			
			if (item)
			{
				var index:int;
				if (type == UIConst.HORIZONTAL)
					index = i;
				else if (type == UIConst.VERTICAL)
					index = j;
				else
					index = j * columnCount + i;
				
				var d:* = (data && index < data.length) ? data[index] : null;
				item.data = d;
				
				if (toggleOnClick)
					item.selected = d && (d == selectedData);
				
				if (autoReszieItemContent)
				{
					item.content.width = columnWidth;
					item.content.height = rowHeight;
				}
			}
			return item;
		}
		
		/**
		 * 刷新某个数据 
		 * @param data
		 * 
		 */
		public function refreshData(data:*):void
		{
			var p:Point = getPointFromData(data);
			if (p)
				refreshIndex(p.x,p.y);
		}
		
		/**
		 * 刷新元素的内容 
		 * 
		 */
		public function refresh():void
		{
			var screen:Rectangle = getItemRect(getLocalScreen());
			if (screen)
			{
				for (var j:int = screen.top;j < screen.bottom;j++)
					for (var i:int = screen.left;i < screen.right;i++)
						refreshIndex(i,j);	
			}
			render();
		}
		/**
		 * 移除全部 
		 * 
		 */		
		public function removeAll():void
		{
			var item:DisplayObject;
			for (var i:int = 0;i < columnCount;i++)
				for (var j:int = 0;j < rowHeight;j++)
				{
					item = getItemAt(i,j);
					if (item && item is UIBase)
						(item as UIBase).destory();
				}
			clear();
			_data = null;
		}
		/**
		 * 根据数据移除 
		 * @param v
		 * 
		 */		
		public function removeData(index:uint):void
		{
			var item:DisplayObject = getRender(data[index]);
			if(item)
				removeRender(item);
		}
		/**
		 * 根据对象移除 
		 * @param item
		 * 
		 */		
		public function removeRender(item:DisplayObject):void
		{
			var i:int = item.x / columnWidth;
			var j:int = item.y / rowHeight;
			var index:uint;
			if (type == UIConst.HORIZONTAL)
				index = i;
			else if (type == UIConst.VERTICAL)
				index = j;
			else
				index = j * columnCount + i;
			removeContent(i,j);
			data.splice(index,1);
			if (item && item is UIBase)
				(item as UIBase).destory();
			render();
		}
		private function removeContent(i:int,j:int):void
		{
			var ary:Array=[];
			var id:int;
			var jd:int;
			for (jd = 0;jd < rowCount;jd++)
			{
				for(id = 0;id < columnCount;id++)
				{
					if(id==i&&jd==j)
					{
					}else{
						if(contents[id + ":" +jd])
							ary.push(contents[id + ":" +jd]);
					}
				}
			}
			var index:uint=0;
			var len:uint=ary.length;
			for (jd = 0;jd < rowCount;jd++)
			{
				for(id = 0;id < columnCount;id++)
				{
					if(index<len)
					{
						contents[id + ":" +jd]= ary[index];
						setItemPosition(contents[id + ":" +jd],id,jd);
						index++;
					}else{
						delete contents[id + ":" +jd];
					}
				}
			}
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			
			for (var i:int = 0; i < numChildren;i++)
			{
				if (getChildAt(i) is IBase)
					(getChildAt(i) as IBase).destory();
			}
			
			removeEventListener(MouseEvent.CLICK,clickHandler);
			removeEventListener(RepeatEvent.ADD_REPEAT_ITEM,addRepeatItemHandler);
			removeEventListener(RepeatEvent.REMOVE_REPEAT_ITEM,removeRepeatItemHandler);
			
			super.destory();
		}
	}
}