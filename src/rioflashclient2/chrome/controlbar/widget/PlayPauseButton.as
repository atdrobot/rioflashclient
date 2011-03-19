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

  import rioflashclient2.assets.PlayPauseButtonAsset;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;

  import flash.events.Event;
  import flash.events.MouseEvent;

  public class PlayPauseButton extends PlayPauseButtonAsset {
    private var currentState:String;

    private var playingState:String = 'playing';
    private var pausedState:String = 'paused';

    public function PlayPauseButton() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupEventListeners();
      setupBusListeners();
      setupInterface();
      setPausedState();
    }

    private function setupEventListeners():void {
      addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
      addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
      addEventListener(MouseEvent.CLICK, onClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.ENDED, onEnded);
    }

    private function setupInterface():void {
      buttonMode = true;
    }

    public function setPlayingState():void {
      currentState = playingState;
      gotoAndStop(currentState);
    }

    public function setPausedState():void {
      currentState = pausedState;
      gotoAndStop(currentState);
    }

    private function onMouseOver(e:MouseEvent):void {
      gotoAndStop(currentState + "_over");
    }

    private function onMouseOut(e:MouseEvent):void {
      gotoAndStop(currentState);
    }

    private function onClick(e:MouseEvent=null):void {
      if (currentState == playingState) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.PAUSE), EventBus.INPUT);
      } else {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAY), EventBus.INPUT);
      }
    }

    private function onPlay(e:PlayerEvent):void {
      setPlayingState();
    }

    private function onPause(e:PlayerEvent):void {
      setPausedState();
    }

    private function onEnded(e:PlayerEvent):void {
      setPausedState();
    }

    public function get offsetLeft():Number {
      return 0;
    }

    public function get offsetTop():Number {
      return 0;
    }

    public function get align():String {
      return WidgetAlignment.LEFT;
    }
  }
}
