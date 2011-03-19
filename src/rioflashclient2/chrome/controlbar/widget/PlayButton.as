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

﻿package rioflashclient2.chrome.controlbar.widget {
  import caurina.transitions.Tweener;
  
  import rioflashclient2.assets.PlayOverlay;
  
  import flash.events.Event;
  import flash.events.MouseEvent;
  
  public class PlayButton extends PlayOverlay {
    public function PlayButton() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event=null):void {
      setupEventListeners();
    }
    
    public function adjustPosition(x:Number, y:Number):void {
      this.x = Math.round(x);
      this.y = Math.round(y);
    }
    
    private function onOver(e:MouseEvent):void {
      //Tweener.addTween(this, { time: 1, alpha: 0.4 });
    }
    
    private function onOut(e:MouseEvent):void {
      //Tweener.addTween(this, { time: 1, alpha: 1 });
    }
    
    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER,  onOver);
      addEventListener(MouseEvent.ROLL_OUT,   onOut);
      addEventListener(MouseEvent.MOUSE_OVER, onOver);
      addEventListener(MouseEvent.MOUSE_OUT,  onOut);
    }
  }
}
