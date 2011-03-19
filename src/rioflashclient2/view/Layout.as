/*
 * Copyright (C) 2011, Edmundo Albuquerque de Souza e Silva.
 *
 * This file may be distributed under the terms of the Q Public License
 * as defined by Trolltech AS of Norway and appearing in the file
 * LICENSE.QPL included in the packaging of this file.
 *
 * THIS FILE IS PROVIDED AS IS WITH NO WARRANTY OF ANY KIND, INCLUDING
 * THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL,
 * INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING
 * FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
 * WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

package rioflashclient2.view
{
	import flash.display.DisplayObject;
	
	public class Layout 
	{
		private var items:Array;
		public function Layout()
		{
			items = [];
		}
		
		public function addItem(configuration:Object):void
		{
			items.addItem(configuration);	
		}
		
		public function draw():void
		{
			items[1].element.visible = false;
			return;
			for(var index:uint = 0; index<items.length; index++){
				var item:Object = items[index];				
				switch(item.verticalAlign){
					case "TOP":
						item.element.x = index > 0 ? items[index].x : 0;
						item.element.y = index > 0 ? items[index].y : 0;
					break;
					case "BOTTOM":
						item.x = index > 0 ? items[index-1].x : 0;
						item.element.y = index > 0 ? items[index-1].y + items[index-1].height : 0;
					break;
					case "LEFT":
						item.x = index > 0 ? items[index-1].x+items[index-1].y : 0;
						item.element.y = index > 0 ? items[index-1].y : 0;
					case "PAGEBOTTOM":
						item.x = index > 0 ? items[index-1].x : 0;
						item.element.y = index > 0 ? item.element.stage.stageHeight - item.element.height : 0;
					break;
				}
				trace(item.verticalAlign, item.element);

				
			}
				
		}
	}
}