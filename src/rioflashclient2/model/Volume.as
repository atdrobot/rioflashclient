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

package rioflashclient2.model {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  
  public class Volume {
    private var currentVolumeLevel:Number;
    private var lastOnVolumeLevel:Number = 1;
    
    public function Volume() {
      setupInputBusListeners();
    }
    
    private function isMuted():Boolean {
      return currentVolumeLevel == 0;
    }
    
    private function saveLastOnVolumeLevel():void {
      if (currentVolumeLevel > 0) {
        lastOnVolumeLevel = currentVolumeLevel;
      }
    }
    
    private function changeVolumeLevel(level:Number):void {
      saveLastOnVolumeLevel();
      currentVolumeLevel = level;
      EventBus.dispatch(new PlayerEvent(PlayerEvent.VOLUME_CHANGE, level));
    }
    
    private function onInputMute(e:PlayerEvent):void {
      if (!isMuted()) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.MUTE));
        
        changeVolumeLevel(0);
      }
    }
    
    private function onInputUnmute(e:PlayerEvent):void {
      if (isMuted()) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.UNMUTE));
        
        changeVolumeLevel(lastOnVolumeLevel);
      }
    }
    
    private function onInputVolumeChange(e:PlayerEvent):void {
      changeVolumeLevel(e.data);
    }
    
    private function setupInputBusListeners():void {
      EventBus.addListener(PlayerEvent.MUTE, onInputMute, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.UNMUTE, onInputUnmute, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onInputVolumeChange, EventBus.INPUT);
    }
  }
}