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

  import rioflashclient2.assets.FullScreenButtonAsset;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;

  import flash.display.StageDisplayState;
  import flash.events.Event;
  import flash.events.FullScreenEvent;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.ui.Keyboard;

  public class FullScreenButton extends FullScreenButtonAsset{
    protected var currentState:String;

    protected var fullScreenState:String = 'fullscreen';
    protected var normalState:String = 'normal';

    public function FullScreenButton() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);

    }

    private function init(e:Event=null):void {
      stop();
      setupEventListeners();
      setupBusListeners();
      setupInterface();
      setNormalState();
    }

    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
      addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
      addEventListener(MouseEvent.CLICK, onClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.ENTER_FULL_SCREEN, onEnterFullScreen);
      EventBus.addListener(PlayerEvent.EXIT_FULL_SCREEN, onExitFullScreen);
    }

    private function setupInterface():void {
      buttonMode = true;
    }

    public function setFullScreenState():void {
      currentState = fullScreenState;
      gotoAndStop(currentState);
    }

    public function setNormalState():void {
      currentState = normalState
      gotoAndStop(currentState);
    }

    private function onMouseOver(e:MouseEvent):void {
      gotoAndStop(currentState+"_over");
    }

    private function onMouseOut(e:MouseEvent):void {
      gotoAndStop(currentState);
    }

    protected function onClick(e:MouseEvent):void {
      if (currentState == fullScreenState) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.EXIT_FULL_SCREEN), EventBus.INPUT);
      } else {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.ENTER_FULL_SCREEN), EventBus.INPUT);
      }
    }

    private function onEnterFullScreen(e:PlayerEvent):void {
      setFullScreenState();
    }

    private function onExitFullScreen(e:PlayerEvent):void {
      setNormalState();
    }

    public function get offsetLeft():Number {
      return 2;
    }

    public function get offsetTop():Number {
      return 0;
    }

    public function get align():String {
      return WidgetAlignment.RIGHT;
    }
  }
}
