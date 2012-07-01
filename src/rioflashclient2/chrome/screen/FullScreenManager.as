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

package rioflashclient2.chrome.screen {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  
  import flash.display.Stage;
  import flash.display.StageDisplayState;
  import flash.events.FullScreenEvent;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  public class FullScreenManager {
    private var logger:Logger = Log.getLogger('FullScreenManager');
    
    private var stage:Stage;
    
    public function FullScreenManager(stage:Stage) {
      this.stage = stage;
      
      setupEventListeners();
      setupInputBusListeners();
    }
    
    private function setupEventListeners():void {
      stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenChanged);
    }
    
    private function setupInputBusListeners():void {
      EventBus.addListener(PlayerEvent.ENTER_FULL_SCREEN, onEnterFullScreen, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.EXIT_FULL_SCREEN, onExitFullScreen, EventBus.INPUT);
    }
    
    private function onEnterFullScreen(e:PlayerEvent):void {
      stage.displayState = StageDisplayState.FULL_SCREEN;
    }
    
    private function onExitFullScreen(e:PlayerEvent):void {
      stage.displayState = StageDisplayState.NORMAL;
    }
    
    private function fullScreenChanged(e:FullScreenEvent):void {
      if (e.fullScreen) {
        logger.info('Entering full screen.');
        EventBus.dispatch(new PlayerEvent(PlayerEvent.ENTER_FULL_SCREEN));
      } else {
        logger.info('Exiting full screen.');
        EventBus.dispatch(new PlayerEvent(PlayerEvent.EXIT_FULL_SCREEN));
      }
    }
  }
}