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

package rioflashclient2.event {

  import flash.events.Event;

  /**
   * Classe que define os eventos da classe player.
   * @author LAND ???
   * 
   */  
  public class PlayerEvent extends Event {
    public static const LOAD                        :String = "onLoad";
    public static const PLAY                        :String = "onPlay";
    public static const PAUSE                       :String = "onPause";
    public static const STOP                        :String = "onStop";

    public static const ENDED                       :String = "onVideoEnded";

    public static const SEEK                        :String = "onSeek";
    public static const TOPICS_SEEK                 :String = "onTopicsSeek";

    public static const DURATION_CHANGE            :String = "onDurationChange";
    public static const PLAYAHEAD_TIME_CHANGED      :String = "onPlayaheadTimeChanged";
    public static const NEED_TO_KEEP_PLAYAHEAD_TIME :String = "onNeedToKeepPlayaheadTime";

    public static const VOLUME_CHANGE               :String = "onVolumeChange";
    public static const MUTE                        :String = "onMute";
    public static const UNMUTE                      :String = "onUnmute";

    public static const ENTER_FULL_SCREEN           :String = "onEnterFullScreen";
    public static const EXIT_FULL_SCREEN            :String = "onExitFullScreen";

    public static const BUFFER_LENGTH_CHANGE        :String = "onBufferLengthChange";
    public static const STREAM_QUALITY_CHANGE       :String = "onStreamQualityChange";

    public var data:*;

    public function PlayerEvent(type:String, data:*=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      super(type, bubbles, cancelable);

      this.data = data;
    }

    public override function clone():Event {
      return new PlayerEvent(type, this.data, bubbles, cancelable);
    }

    public override function toString():String {
      return formatToString("PlayerEvent", "type", "data", "bubbles", "cancelable", "eventPhase");
    }
  }
}
