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

package rioflashclient2.chrome.controlbar.widget {
  import com.yahoo.astra.fl.controls.Tree;
  import com.yahoo.astra.fl.controls.treeClasses.*;

  import fl.events.ListEvent;

  import flash.events.Event;
  import flash.events.MouseEvent;

  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.metadata.CuePoint;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Topics;
  import rioflashclient2.net.StateMonitor;

  public class TopicsNavigator extends Tree {
    private var logger:Logger = Log.getLogger('TopicsNavigator');
    private var duration:Number = 0;
    private var lesson:Lesson;
    private var topics:Topics;
    private var slideSync:Boolean = true;

    public function TopicsNavigator() {
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupEventListeners();
      setupBusListeners();
      resize();
    }

    private function resize():void {
      this.width = 320;
      this.height = stage.height - Configuration.getInstance().playerHeight;
    }

    private function onClick(ev:ListEvent):void {
      this.openAllNodes();
      //EventBus.dispatch(new PlayerEvent(PlayerEvent.TOPICS_SEEK, ev.item.time), EventBus.INPUT);
	  StateMonitor.Instance.Jump("TOPIC_CHANGED", ev.item.time); //ev.index;
	  EventBus.dispatch(new PlayerEvent(PlayerEvent.TOPICS_SEEK, ev), EventBus.INPUT);
    }

    private function onDurationChange(e:PlayerEvent):void {
      duration = e.data;
    }

    private function onSlideSyncChanged(e:SlideEvent):void {
      slideSync = e.slide.sync;
    }

    private function onTopicCuePoint(event:TimelineMetadataEvent):void
    {
      var cuePoint:CuePoint = event.marker as CuePoint;
      if (cuePoint.name == "Topic") {
        logger.info("Topic CuePoint reached=" + cuePoint.time);
        highlightTopic(cuePoint.time);
      }
    }

    private function highlightTopic(time:Number):void {
      this.selectedIndex = this.dataProvider.getItemIndex(this.findNode('time', time.toString()));
	  if( this.selectedIndex != -1 )
	  {
	      var topicTime:Number = this.topics.topicTimes[this.selectedIndex];
	      StateMonitor.Instance.SetTopicInfo(this.selectedIndex + 1, topicTime);
	  }
    }

    private function onSeek(e:PlayerEvent):void {
      var seekPercentage:Number = (e.data as Number);
      var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
      highlightTopic(findNearestTopic(seekPosition));
    }

    private function onSlideChanged(e:SlideEvent):void {
      if (slideSync) {
        highlightTopic(findNearestTopic(e.slide.time));
      }
    }

    private function findNearestTopic(seekPosition:Number):Number {
      var last:Number = this.topics.topicTimes[0];
      for each (var topicTime:Number in this.topics.topicTimes) {
        if (seekPosition < topicTime) {
          return last;
        }
        last = topicTime;
      }
      return last;
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    private function setupEventListeners():void {
      this.addEventListener(ListEvent.ITEM_CLICK, onClick);
    }

    private function setupBusListeners():void {
      EventBus.addListener(LessonEvent.RESOURCES_LOADED, onLessonResourcesLoaded);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onTopicCuePoint);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);
      EventBus.addListener(SlideEvent.SLIDE_CHANGED, onSlideChanged, EventBus.INPUT);
      EventBus.addListener(SlideEvent.SLIDE_SYNC_CHANGED, onSlideSyncChanged, EventBus.INPUT);
    }

    private function onLessonResourcesLoaded(e:LessonEvent):void {
      this.lesson = (e.lesson as Lesson);
      this.topics = (this.lesson.topics as Topics);
      var topicsXML:XML = e.lesson.topics.toXML();
      this.dataProvider = new TreeDataProvider(topicsXML);
      this.openAllNodes();
	  StateMonitor.Instance.SetTopics(this.topics.topicTimes);
    }
  }
}