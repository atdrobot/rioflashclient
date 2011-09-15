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

package rioflashclient2.player {
  import br.com.stimuli.loading.BulkLoader;
  import br.com.stimuli.loading.BulkProgressEvent;

  import caurina.transitions.Tweener;

  import flash.events.Event;
  import flash.display.MovieClip;
  import flash.display.Loader;
  import flash.geom.Rectangle;
  import flash.utils.setTimeout;
  import flash.system.LoaderContext;
  import flash.system.Security;
  import flash.system.ApplicationDomain;
  import flash.system.SecurityDomain;

  import org.osmf.events.TimeEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.metadata.CuePoint;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Slide;
  import rioflashclient2.model.Video;
  import rioflashclient2.net.StateMonitor;

  public class SlidePlayer extends MovieClip {
    private var logger:Logger = Log.getLogger('SlidePlayer');
    private var loader:BulkLoader;

    private var lesson:Lesson;
    private var slides:Array;
    private var currentSlideIndex:Number;
    private var container:MovieClip;
    private var sync:Boolean = true;
    private var duration:Number = 0;
    private var videoPlayerCurrentTime:Number;
    private var requestedIndex:Number;
    private var loading:Boolean = false;
    private var dataLoaded:Boolean = false;

    private var measuredWidth:Number;
    private var measuredHeight:Number;

    public function SlidePlayer() {
      this.name = 'SlidePlayer';
      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupBusListeners();

      container = new MovieClip();
      addChild(container);
    }

    private function onLoad(e:PlayerEvent):void {
      trace("loading slides");
      lesson = e.data.lesson;
      slides = lesson.slides;
      duration = lesson.duration;
      dataLoaded = true;
      load();
    }

    public function load():void {
      loader = new BulkLoader('slides');
      for ( var i:uint = 0; i< slides.length; i++) {
        var slide:Slide = slides[i];
        var slideURL:String = Configuration.getInstance().resourceURL(slide.relative_path);

        var myLoaderContext:LoaderContext = new LoaderContext();
        if (Security.sandboxType!='localTrusted') myLoaderContext.securityDomain = SecurityDomain.currentDomain;
        var current:ApplicationDomain = ApplicationDomain.currentDomain;
        myLoaderContext.applicationDomain = new ApplicationDomain();
        loader.add(slideURL, { id: ("slide_" + i), priority: (slides.length - i), type: "movieclip", context: myLoaderContext });
        loader.get("slide_" + i).addEventListener(Event.COMPLETE, onSingleItemLoaded);
      }
      loader.get("slide_0").addEventListener(Event.COMPLETE, onFirstItemLoaded);
      if (slides.length > 1) {
        loader.get("slide_1").addEventListener(Event.COMPLETE, onSecondItemLoaded);
      }
      loader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
      loader.addEventListener(BulkLoader.PROGRESS, onAllProgress);

      trace("starting loading slides");
      loader.start(1);
    }

    public function onSingleItemLoaded(e:Event):void {
      trace(e.target.id);
      trace("1 more slide loaded");
    }

    public function onFirstItemLoaded(e:Event):void {
      trace("first slide loaded");
      addToContainer(0, true);
      if (slides.length == 1) {
        lesson.video().play();
      }
    }

    public function onSecondItemLoaded(e:Event):void {
      trace("second slide loaded, starting to play");
      lesson.video().play();
    }

    public function onAllItemsLoaded(e:BulkProgressEvent) : void {
      trace("all slides loaded");
	  StateMonitor.Instance.SetSlides(this.slides);
    }

    public function onAllProgress(e:BulkProgressEvent) : void {
      //trace(e.loadingStatus());
    }

    private function onFirstSlide(e:SlideEvent):void {
      if (dataLoaded) {
	    StateMonitor.Instance.SlideChanged(0, "FIRST");
        showSlide(0)
      }
    }

    private function onLastSlide(e:SlideEvent):void {
      if (dataLoaded) {
       StateMonitor.Instance.SlideChanged(slides.length - 1, "LAST");
       showSlide(slides.length - 1);
      }
    }

    private function onPreviousSlide(e:SlideEvent):void {
      if (dataLoaded) {
        if (currentSlideIndex > 0) {
		  StateMonitor.Instance.SlideChanged(currentSlideIndex - 1, "PREV");
          showSlide(currentSlideIndex - 1);
        }
      }
    }

    private function onNextSlide(e:SlideEvent):void {
      if (dataLoaded) {
        if (currentSlideIndex < (slides.length - 1)) {
		  StateMonitor.Instance.SlideChanged(currentSlideIndex + 1, "NEXT");
          showSlide(currentSlideIndex + 1);
        }
      }
    }

    private function findNearestSlide(seekPosition:Number):Number {
      var last:Number = 0;
      for (var i:uint = 0; i < slides.length; i++) {
        if (seekPosition < slides[i].time) {
          return i - 1;
        }
        last = i;
      }
      return last;
    }

    private function onDurationChange(e:PlayerEvent):void {
      duration = e.data;
    }

    private function onCurrentTimeChange(e:TimeEvent):void {
      videoPlayerCurrentTime = e.time;
	  StateMonitor.Instance.SetTime(e.time);
    }

    private function onSlideSyncChanged(e:SlideEvent):void {
      sync = e.slide.sync;
      if (sync) {
        var time:Number = slides[findNearestSlide(videoPlayerCurrentTime)].time
        showSlideByPosition(time, true);
      }
	  StateMonitor.Instance.SetSlideSync(this.sync);
    }

    private function onSeek(e:PlayerEvent):void {
      if (sync) {
        var seekPercentage:Number = (e.data as Number);
        if (seekPercentage <= 0) {
          seekPercentage = 1 / duration;
        }
        var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
        logger.info('Slide Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
        showSlideByPosition(seekPosition);
      }
    }

    private function onTopicsSeek(e:PlayerEvent):void {
      if (sync) {
        var seekPosition:Number = e.data.item.time;
        logger.info('Slide Seeking to position {0} in seconds.', seekPosition);
        showSlideByPosition(seekPosition);
      }
    }

    private function onSlideCuePoint(event:TimelineMetadataEvent):void {
      if (sync) {
        var cuePoint:CuePoint = event.marker as CuePoint;
        if (cuePoint.name.indexOf("Slide") != -1) {
          var slideNumber:Number = Number(cuePoint.name.substring(cuePoint.name.indexOf("_") + 1)) -1;
          showSlide(slideNumber, true);
        } else if (cuePoint.name.indexOf("Action") != -1) {
          var callback:String = cuePoint.name.substring(cuePoint.name.indexOf("_") + 1);
          currentSlide().content[callback]();
        }
      }
    }

    private function showSlideByPosition(requestedPosition:Number, ignoreEvent:Boolean=false):void {
      showSlide(findNearestSlide(requestedPosition), ignoreEvent);
    }

    private function currentSlide():Loader {
      return container.getChildByName("slide_" + currentSlideIndex) as Loader;
    }

    public function showSlide(index:Number, ignoreEvent:Boolean=false):void {
      trace("START show slide");
      if (currentSlideIndex != index && !loading) {
        trace("will load slide");

        clearContainer();

        if (slideLoader(index)) {
          trace("already loaded");

          addToContainer(index, ignoreEvent);
        } else {
          trace("not loaded, loading");

          if (sync) {
            EventBus.dispatch(new PlayerEvent(PlayerEvent.PAUSE));
          }

          requestedIndex = index;
          repriorizeByIndex(requestedIndex);
          loading = true;
          loader.get("slide_" + index).addEventListener(Event.COMPLETE, onRequestedSlideLoaded);
        }
      }
	  StateMonitor.Instance.SetSlideInfo(index);
      trace("END show slide")
    }

    private function repriorizeByIndex(index:Number):void {
      loader.pauseAll();
      for ( var i:uint = index; i< slides.length; i++) {
        loader.changeItemPriority("slide_" + i, (slides.length - i + index));
      }
      for ( var j:uint = 0; j< index; j++) {
        loader.changeItemPriority("slide_" + j, (slides.length - j - index));
      }
      loader.resumeAll();
    }

    private function addToContainer(index:Number, ignoreEvent:Boolean = false):void {
      trace("START add to container");
      clearContainer();
      currentSlideIndex = index;
      container.addChild(slideLoader(index));
      resizeContainer();
      if (!ignoreEvent) {
        dispatchSlideChanged(index);
      }
      trace("END add to container");
    }

    private function dispatchSlideChanged(index:Number):void {
      trace("dispatching slide changed")
      var time:Number = slides[index].time;
      EventBus.dispatch(new SlideEvent(SlideEvent.SLIDE_CHANGED, { slide: index, time: time }), EventBus.INPUT);
    }

    private function onRequestedSlideLoaded(e:Event):void {
      trace("START requested slide loaded")
      loading = false;
      addToContainer(requestedIndex, true);
      if (sync) {
        EventBus.dispatch(new PlayerEvent(PlayerEvent.PLAY));
      }
      trace("END requested slide loaded")
    }

    private function clearContainer():void {
      trace("START clear container");
      var slide:Loader = currentSlide();
      if (slide) {
        container.removeChild(slide);
      }
      trace("END clear container");
    }

    private function slideLoader(index:Number):Loader {
      var name:String = "slide_" + index;

      if (loader.getContent(name) == null) {
        return null;
      }

      var slide:Loader = loader.getContent(name).parent
      slide.name = name;
      return slide;
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    public function setSize(newWidth:Number, newHeight:Number):void {
      this.width = newWidth;
      this.height = newHeight;
      resizeContainer();
    }

    private function resizeContainer():void {
      trace("START resize container");
      var slide:Loader = currentSlide();
      var maskWidth:Number;
      var maskHeight:Number;

      if (slide) {
        if (slide.contentLoaderInfo.width > slide.contentLoaderInfo.height) {
          slide.width = (this.width * slide.content.width) / slide.contentLoaderInfo.width;
          slide.scaleY = slide.scaleX;
          maskWidth = this.width;
          maskHeight = (this.width * slide.contentLoaderInfo.height) / slide.contentLoaderInfo.width;

          if (measuredHeight < maskHeight) {
            slide.height = (this.height * slide.content.height) / slide.contentLoaderInfo.height;
            slide.scaleX = slide.scaleY;

            maskWidth = (this.height * slide.contentLoaderInfo.width) / slide.contentLoaderInfo.height;
            maskHeight = this.height;
          }
        } else {
          slide.height = (this.height * slide.content.height) / slide.contentLoaderInfo.height;
          slide.scaleX = slide.scaleY;

          maskWidth = (this.height * slide.contentLoaderInfo.width) / slide.contentLoaderInfo.height;
          maskHeight = this.height;

          if (measuredWidth < maskWidth) {
            slide.width = (this.width * slide.content.width) / slide.contentLoaderInfo.width;
            slide.scaleY = slide.scaleX;

            maskWidth = this.width;
            maskHeight = (this.width * slide.contentLoaderInfo.height) / slide.contentLoaderInfo.width;
          }
        }
      }

      this.scrollRect = new Rectangle(0,0, maskWidth, maskHeight);
      trace("END resize container");
    }

    override public function set width(value:Number):void
    {
      measuredWidth = value;
    }

    override public function get width():Number
    {
      return measuredWidth;
    }

    override public function set height(value:Number):void
    {
      measuredHeight = value;
    }

    override public function get height():Number
    {
      return measuredHeight;
    }

    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);
      EventBus.addListener(PlayerEvent.DURATION_CHANGE, onDurationChange);

      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onSlideCuePoint);

      EventBus.addListener(SlideEvent.FIRST_SLIDE, onFirstSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.PREV_SLIDE, onPreviousSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.NEXT_SLIDE, onNextSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.LAST_SLIDE, onLastSlide, EventBus.INPUT);
      EventBus.addListener(SlideEvent.SLIDE_SYNC_CHANGED, onSlideSyncChanged, EventBus.INPUT);
    }
  }
}
