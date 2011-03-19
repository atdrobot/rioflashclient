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

package rioflashclient2.user {
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.model.Volume;
  
  import flash.net.SharedObject;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  public class VolumeSettings {
    private static const USER_VOLUME_SETTINGS_COOKIE_NAME:String = 'playerVolume';
    private static const DEFAULT_USER_VOLUME_LEVEL:Number = 1;
    
    private var logger:Logger = Log.getLogger('VolumeSettings');
    
    private var userSettings:SharedObject;
    private var volume:Volume;
    
    public function VolumeSettings() {
      userSettings = SharedObject.getLocal(USER_VOLUME_SETTINGS_COOKIE_NAME, "/");
      volume = new Volume();
      
      setupEventListeners();
    }
    
    public function restore():void {
      load();
      volumeChanged();
    }
    
    private function load():void {
      logger.info('Loading user volume settings...');
      
      if (userSettings.data.volume == undefined) {
        logger.info('User does not have volume settings, using default.');
        level = DEFAULT_USER_VOLUME_LEVEL;
      } else {
        logger.info('Using user volume settings, volume level: ' + level);
      }
    }
    
    private function volumeChanged():void {
      EventBus.dispatch(new PlayerEvent(PlayerEvent.VOLUME_CHANGE, level), EventBus.INPUT);
    }
    
    public function get level():Object {
      return userSettings.data.volume;
    }
    
    public function set level(level:Object):void {
      logger.debug('Saving user volume level: ' + level);
      
      userSettings.data.volume = level;
      userSettings.flush();
    }
    
    private function setupEventListeners():void {
      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onVolumeChange);
    }
    
    private function onVolumeChange(e:PlayerEvent):void {
      level = e.data as Number;
    }
  }
}