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

﻿package rioflashclient2.chrome.screen {
  import rioflashclient2.event.LoggerEvent;
  
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.text.TextField;

  public class DebugConsole extends Sprite {
    private static const PADDING:Number = 20;
    
    private var console:TextField = new TextField();
    
    private var autoScrollButton:MovieClip = new MovieClip();
    
    public function DebugConsole() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    public function init(e:Event=null):void {
      setupInterface();
      setupEventListeners();
    }
    
    public function onLogMessage(e:LoggerEvent):void {
      var currentScrollV:Number = console.scrollV;
      
      console.appendText(e.message + "\n");
      
      if (autoScrollButton.scrolling) {
        console.scrollV = console.maxScrollV;
      } else {
        console.scrollV = currentScrollV; // keeps scroll locked.
      }
    }
    
    private function setupInterface():void {
      visible = false;
      
      setupConsole();
      setupAutoScrollButton();
      
      resizeAndPosition();
    }
    
    private function setupConsole():void {
      console.multiline = true;
      console.background = true;
      console.backgroundColor = 0xffffff;
      console.alpha = 0.7;
      
      addChild(console);
    }
    
    private function setupAutoScrollButton():void {
      autoScrollButton.scrolling = true;
      autoScrollButton.buttonMode = true;
      
      drawAutoScrollButton();
      addChild(autoScrollButton);
    }
    
    private function setupEventListeners():void {
      stage.addEventListener(Event.RESIZE, resizeAndPosition);
      stage.addEventListener(KeyboardEvent.KEY_UP, toggleConsoleVisibility);
      
      autoScrollButton.addEventListener(MouseEvent.CLICK, toogleScroll);
    }
    
    private function resizeAndPosition(e:Event=null):void {
      console.width = stage.stageWidth - PADDING * 2;
      console.height = stage.stageHeight * 0.5 - PADDING; // 50% of stage height
      console.y = PADDING;
      console.x = PADDING;
      
      autoScrollButton.x = console.x + console.width;
      autoScrollButton.y = console.y;
    }
    
    private function toogleScroll(e:MouseEvent):void {
      autoScrollButton.scrolling = !autoScrollButton.scrolling;
      
      drawAutoScrollButton();
    }
    
    private function drawAutoScrollButton():void {
      var autoScrollBorderColor:uint = autoScrollButton.scrolling ? 0xFFCC00 : 0xFF0000;
      var autoScrollAlpha:uint = autoScrollButton.scrolling ? 1 : 0;
      
      autoScrollButton.graphics.clear();
      autoScrollButton.graphics.beginFill(0x000, autoScrollAlpha);
      autoScrollButton.graphics.lineStyle(1, autoScrollBorderColor);
      autoScrollButton.graphics.drawRect(0, 0, 10, 10);
      autoScrollButton.graphics.endFill();
    }
    
    private function toggleConsoleVisibility(e:KeyboardEvent):void {
      if (e.ctrlKey && e.altKey && e.shiftKey && e.keyCode == 68) { // ctrl + alt + shift + D
        visible = !visible;
        
        if (visible) {
          parent.setChildIndex(this, parent.numChildren - 1);
        }
      }
    }
  }
}
