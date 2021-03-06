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

package rioflashclient2.elements
{
  import flash.events.Event;
  import flash.media.Video;
  import flash.net.NetStream;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.media.MediaElement;
  import org.osmf.net.NetClient;
  import org.osmf.net.NetStreamCodes;
  import org.osmf.net.NetStreamSeekTrait;
  import org.osmf.traits.LoadState;
  import org.osmf.traits.LoadTrait;
  import org.osmf.traits.MediaTraitType;
  import org.osmf.traits.PlayTrait;
  import org.osmf.traits.SeekTrait;
  import org.osmf.traits.TimeTrait;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.net.pseudostreaming.DefaultSeekDataStore;

  public class PseudoStreamingSeekTrait extends NetStreamSeekTrait
  {
    private var logger:Logger = Log.getLogger('PseudoStreamingSeekTrait');

    private var proxiedElement:MediaElement;
    private var loadTrait:LoadTrait;
    private var netStream:NetStream;
    private var audioDelay:Number = 0;
    private var seekDataStore:DefaultSeekDataStore;
    private var playaheadTime:Number = 0;
    private var resource_file:String;

    public function PseudoStreamingSeekTrait(temporal:TimeTrait, loadTrait:LoadTrait, netStream:NetStream, resource_file:String)
    {
      super(temporal, loadTrait, netStream);
      this.loadTrait = loadTrait;
      this.netStream = netStream;
      this.resource_file = resource_file;
      NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
    }

    private function onMetaData(info:Object):void
    {
      audioDelay = info.hasOwnProperty("audiodelay") ? info.audiodelay : 0;
      logger.info('Loading video metadata...');
      seekDataStore = DefaultSeekDataStore.create(info);
      seekDataStore.reset();
      EventBus.dispatch(new PlayerEvent(PlayerEvent.NEED_TO_KEEP_PLAYAHEAD_TIME, seekDataStore.needToKeepPlayAheadTime()));
    }

    override public function canSeekTo(time:Number):Boolean
    {
      var result:Boolean =  timeTrait
      ? ( isNaN(time) == false
        &&  time >= 0
        &&  (time <= timeTrait.duration || time <= timeTrait.currentTime)
      )
        :   false;

      return result;
    }

    override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void
    {
      if (time <= 0) {
        return;
      }
      var duration:Number = timeTrait.duration;
      var downloadProgressPercentage:Number = loadTrait.bytesLoaded / loadTrait.bytesTotal;
      var requestedTimePercentage:Number = time / duration;

      var bufferStart:Number = playaheadTime;
      var bufferEnd:Number = downloadProgressPercentage * (duration - playaheadTime);
      var bufferPercentage:Number = (bufferStart + bufferEnd) / duration;

      if ((requestedTimePercentage * duration) >= playaheadTime && requestedTimePercentage <= bufferPercentage) {
        super.seekingChangeStart(newSeeking, time);
      } else {
        if (newSeeking) {
          if (seekDataStore.allowRandomSeek()) {
            var seekPosition:Number = seekDataStore.getNearestKeyFramePosition(time);
            logger.info('Server seeking to position {0} in seconds', seekDataStore.keyFrameTime());
            playaheadTime = seekDataStore.keyFrameTime();
            netStream.play(Configuration.getInstance().resourceURL(resource_file, seekPosition));

            if (time == 1) {
              EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAYAHEAD_TIME_CHANGED, 1));
            } else {
              EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAYAHEAD_TIME_CHANGED, seekDataStore.keyFrameTime()));
            }
          } else {
            logger.info('ServerSeek not supported by media element');
          }
        }
      }
    }
  }
}