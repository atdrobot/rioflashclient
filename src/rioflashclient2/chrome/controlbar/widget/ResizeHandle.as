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

package rioflashclient2.chrome.controlbar.widget
{
  import fl.controls.Button;
  import fl.events.ComponentEvent;

  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.DisplayObject;
  import flash.display.Shape;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.geom.Rectangle;

  import rioflashclient2.assets.HorizontalHandleIcon;
  import rioflashclient2.event.DragEvent;

  [Event(name="dragUpdate",type="rioflashclient2.event.DragEvent")]
  public class ResizeHandle extends Sprite
  {
    protected var startDragPosition:Number;
    private var rectangleConstrains:Rectangle;
    private var ghost:Sprite;
    private var slide:HorizontalHandleIcon;
    public function ResizeHandle()
    {

      super();
      buttonMode = true;
      useHandCursor = true;
      addEventListener(MouseEvent.MOUSE_DOWN,resizeHandleDownHandler);
      slide = new HorizontalHandleIcon();
      ghost = new Sprite();
      ghost.graphics.lineStyle(3,0x000000);
      ghost.graphics.lineTo(0,100);
      ghost.visible = false;
      addChild(slide);
      addChild(ghost);
    }
    public function setSize(newWidth:Number, newHeight:Number):void{
      slide.icon.y = newHeight/2;
      slide.bg.height = newHeight;
      ghost.graphics.lineTo(0,newHeight);
    }
    public function constrains(x:Number, y:Number, w:Number, h:Number):void{
      var point1:Point = globalToLocal(new Point(x,y));
      rectangleConstrains = new Rectangle(point1.x, point1.y, w, point1.y);
    }

    protected function resizeHandleDownHandler(event:MouseEvent):void
    {
      ghost.visible = true;
      ghost.startDrag(true,rectangleConstrains);
      stage.addEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler);
      addEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler);
      event.updateAfterEvent();
    }

    public function getX():Number
    {
      return localToGlobal(new Point(slide.x,0)).x;
    }
    protected function handleDragStopHandler(event:MouseEvent):void
    {
      event.updateAfterEvent();
      ghost.stopDrag();
      removeEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler);
      stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragStopHandler);
      var newx:Number = ghost.x;
      slide.x = Math.round(newx-slide.width/2);
      ghost.visible = false;
      dispatchEvent(new DragEvent(DragEvent.DRAG_END));

    }
  }
}