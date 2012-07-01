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
  import caurina.transitions.Tweener;

  import flash.events.ErrorEvent;
  import flash.events.Event;

  import org.osmf.elements.ProxyElement;
  import org.osmf.elements.VideoElement;
  import org.osmf.events.*;
  import org.osmf.events.LoadEvent;
  import org.osmf.events.MediaPlayerStateChangeEvent;
  import org.osmf.events.TimeEvent;
  import org.osmf.events.TimelineMetadataEvent;
  import org.osmf.layout.ScaleMode;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  import org.osmf.media.MediaElement;
  import org.osmf.media.MediaPlayerSprite;
  import org.osmf.media.MediaPlayerState;
  import org.osmf.media.URLResource;
  import org.osmf.metadata.CuePoint;
  import org.osmf.metadata.CuePointType;
  import org.osmf.metadata.TimelineMarker;
  import org.osmf.metadata.TimelineMetadata;
  import org.osmf.net.NetLoader;
  import org.osmf.traits.LoadTrait;
  import org.osmf.traits.MediaTraitType;
  import org.osmf.traits.SeekTrait;
  import org.osmf.traits.TimeTrait;

  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.elements.PseudoStreamingProxyElement;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.event.SlideEvent;
  import rioflashclient2.media.PlayerMediaFactory;
  import rioflashclient2.model.Lesson;
  import rioflashclient2.model.Slide;
  import rioflashclient2.model.Topics;
  import rioflashclient2.model.Video;
  import rioflashclient2.net.Messages.ActionMessage;
  import rioflashclient2.net.Messages.Message;
  import rioflashclient2.net.Messages.StartSessionMessage;
  import rioflashclient2.net.RemoteLogger;
  import rioflashclient2.net.RioServerNetLoader;
  import rioflashclient2.net.StateMonitor;
  import rioflashclient2.net.pseudostreaming.DefaultSeekDataStore;

  
  /**
   * Classe Classe responsável pelo controle dos eventos do player de vídeo.
   * @author LAND ???
   * 
   */  
  public class Player extends MediaPlayerSprite {
    private var logger:Logger = Log.getLogger('Player');

    public var lesson:Lesson;
    public var video:Video;
    public var topics:Topics;
    private var slides:Array;
    private var seekDataStore:DefaultSeekDataStore;
    private var duration:Number = 0;
    private var durationCached:Boolean = false;
    private var slideSync:Boolean = true;
    private var videoEnded:Boolean = false;

    private var playaheadTime:Number = 0;
    private var _downloadProgressPercentage:Number;
    private var bytesTotal:Number = 0;

    private var topicsTimelineMetadata:TimelineMetadata;
    private var slidesTimelineMetadata:TimelineMetadata;
    private var slidesActionsTimelineMetadata:TimelineMetadata;

    private var netLoader:NetLoader;

    public function Player() {
      this.name = 'Player';
      super(null, null, new PlayerMediaFactory());

      if (!!stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event=null):void {
      setupMediaPlayer();
      setupInterface();
      setupBusDispatchers();
      setupBusListeners();
    }

    public function load(lesson:Lesson):void {
      this.video = (lesson.video() as Video);
      this.topics = (lesson.topics as Topics);
      this.slides = lesson.slides;
      loadMedia();
    }

    private function onTraitAdd(event:MediaElementEvent):void
    {
      logger.debug('Trait added: ' + event.traitType);
    }

	/**
	 * Função responsável por chamar todas os métodos necessários para carregar os dados da videoaula (vídeo, tópicos e slides). 
	 * 
	 */	
    public function loadMedia():void {
      var url:String = Configuration.getInstance().resourceURL(this.video.file());
      logger.info('Loading video from url: ' + url);
      //RemoteLogger.Instance.SetServer(url.substring(0, url.indexOf("/", 8)));

      netLoader = new RioServerNetLoader();
      var videoElement:VideoElement = new VideoElement(null, netLoader);
      videoElement.resource = new URLResource(url);
      videoElement.smoothing = true;
      videoElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);

      var pseudoStreamingProxyElement:PseudoStreamingProxyElement = new PseudoStreamingProxyElement(videoElement, this.video.file());
      this.media = pseudoStreamingProxyElement;

      topicsTimelineMetadata = new TimelineMetadata(pseudoStreamingProxyElement);
      topicsTimelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, EventBus.dispatch, false, 0, true);
      addTopicsMetadata(this.topics);

      slidesTimelineMetadata = new TimelineMetadata(pseudoStreamingProxyElement);
      slidesTimelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, EventBus.dispatch, false, 0, true);
      addSlidesMetadata(this.slides);

	  //Message.setSessionId();
      slidesActionsTimelineMetadata = new TimelineMetadata(pseudoStreamingProxyElement);
      slidesActionsTimelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, EventBus.dispatch, false, 0, true);
      addSlidesActionsMetadata(this.slides);
    }

    public function addTopicsMetadata(topics:Topics):void {
      for each (var topicTime:Number in topics.topicTimes) {
        var cuePoint:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, topicTime, "Topic", null);
        topicsTimelineMetadata.addMarker(cuePoint);
      }
    }

    public function addSlidesMetadata(slides:Array):void {
      for (var i:uint = 0; i < slides.length; i++) {
        var cuePoint:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, slides[i].time, "Slide_" + (i + 1), null);
        slidesTimelineMetadata.addMarker(cuePoint);
      }
    }

    public function addSlidesActionsMetadata(slides:Array):void {
      for each(var slide:Slide in slides){
        for each(var action:Object in slide.actions){
          var cuePoint:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, action.time, "Action_" + action.callback, null);
          slidesActionsTimelineMetadata.addMarker(cuePoint);
        }
      }
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
      var cuePoint:CuePoint = event.marker as CuePoint;
      var diff:Number = cuePoint.time - this.mediaPlayer.currentTime;
      logger.info("CuePoint type=" + cuePoint.name + " reached=" + cuePoint.time + ", currentTime:" + this.mediaPlayer.currentTime + ", diff="+diff);
    }

	/**
	 * Função de "play" do vídeo 
	 * 
	 */	
    public function play():void {
      logger.info('Playing...');
      fadeIn();
      if (videoEnded) {
        this.mediaPlayer.seek(playaheadTime);
      }
      this.mediaPlayer.play();
	  StateMonitor.Instance.SetState("PLAY");
    }

	/**
	 * Função de "pause" do vídeo 
	 * 
	 */	
    public function pause():void {
      logger.info('Paused...');
      this.mediaPlayer.pause();
	  StateMonitor.Instance.SetState("PAUSE");
    }

	/**
	 * Função que para a exibição do vídeo 
	 * 
	 */	
    public function stop():void {
      logger.info('Stopping...');
      this.mediaPlayer.stop();
	  StateMonitor.Instance.SetState("STOP");
      fadeOut();
    }

    private function onLoad(e:PlayerEvent):void {
      load(e.data.lesson);
    }

	/**
	 * Evento chamado quando é chamada a ação "play" do vídeo 
	 * @param e
	 * 
	 */	
    private function onPlay(e:PlayerEvent):void {
      play();
    }

	/**
	 * Evento chamando quando é chamada a ação "pause" do vídeo 
	 * @param e
	 * 
	 */	
    private function onPause(e:PlayerEvent):void {
      pause();
    }

	/**
	 * Evento chamado quando é chamada a ação "stop" do vídeo 
	 * @param e
	 * 
	 */	
    private function onStop(e:PlayerEvent):void {
      stop();
    }

	/**
	 * Evento chamado quando o volume é alterado 
	 * @param e
	 * 
	 */	
    private function onVolumeChange(e:PlayerEvent):void {
      logger.debug('Volume changed: ' + e.data);
      this.mediaPlayer.volume = e.data;
    }
	/**
	 * Evento chamado quando o áudio entra em estado mudo 
	 * @param e
	 * 
	 */
    private function onMute(e:PlayerEvent):void {
      logger.debug('Volume muted.');
      this.mediaPlayer.muted = true;
    }

	/**
	 * Evento chamado quando o áudio sai do estado mudo. 
	 * @param e
	 * 
	 */	
    private function onUnmute(e:PlayerEvent):void {
      logger.debug('Volume unmuted.');
      this.mediaPlayer.muted = false;
    }

	/**
	 * Evento chamado quando o vídeo acaba 
	 * @param e
	 * 
	 */	
    private function onVideoEnded(e:TimeEvent):void {
      logger.info('Video ended.');
      EventBus.dispatch(new PlayerEvent(PlayerEvent.ENDED, { video: video }));
      videoEnded = true;
      stop();
    }

    private function onSeek(e:PlayerEvent):void {
      var seekPercentage:Number = (e.data as Number);
      if (seekPercentage <= 0) {
        seekPercentage = 1 / duration;
      }
      var seekPosition:Number = calculatedSeekPositionGivenPercentage(seekPercentage);
      seekTo(seekPercentage, seekPosition);
	  StateMonitor.Instance.Jump("PROGRESSBAR_CHANGED", seekPosition);
    }

	/**
	 * Evento chamado quando ocorre um salto no tópico. 
	 * @param e
	 * 
	 */	
    private function onTopicsSeek(e:PlayerEvent):void {
      //var seekPosition:Number = e.data;
	  var seekPosition:Number = e.data.item.time;
	  logger.info(' Tempo do topico: {0} ', seekPosition );
      var seekPercentage:Number = seekPosition / duration;

      seekTo(seekPercentage, seekPosition);
    }

    private function onSlideSyncChanged(e:SlideEvent):void {
      slideSync = e.slide.sync;
    }

	/**
	 * Evento chamado quando um slide muda. Com a mudança do slide é necessário sincronizar o vídeo caso o flag slideSync esteja ligado 
	 * @param e
	 * 
	 */	
    private function onSlideChanged(e:SlideEvent):void {
      if (slideSync) {
        logger.info('Slide syncing to {0}', e.slide.time);
        var seekPosition:Number = e.slide.time;
        var seekPercentage:Number = seekPosition / duration;

        seekTo(seekPercentage, seekPosition);
      }
    }

	/**
	 * Função que faz um salto do vídeo de acordo com o parametro seekPosition 
	 * @param seekPercentage
	 * @param seekPosition
	 * 
	 */	
    private function seekTo(seekPercentage:Number, seekPosition:Number):void {
      if (isInBuffer(seekPercentage)) {
        logger.info('Seeking to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
      } else {
        logger.info('Server seek requested to position {0} in seconds, given percentual {1}.', seekPosition, seekPercentage);
      }
	  
	  //O player nao reconhece o tempo 0
	  if (seekPosition == 0)
        this.mediaPlayer.seek(0.001);
	  else
		this.mediaPlayer.seek(seekPosition);
    }

    private function isInBuffer(seekPercentage:Number):Boolean {
      var bufferStart:Number = playaheadTime;
      var bufferEnd:Number = downloadProgressPercentage * (duration - playaheadTime);
      var bufferPercentage:Number = (bufferStart + bufferEnd) / duration;
      return isAfterPlayahead(seekPercentage) && seekPercentage <= bufferPercentage;
    }

    private function isAfterPlayahead(seekPercentage:Number): Boolean {
      return (seekPercentage * duration) >= playaheadTime;
    }

    public function get downloadProgressPercentage():Number {
      return _downloadProgressPercentage;
    }

    public function set downloadProgressPercentage(percentage:Number):void {
      _downloadProgressPercentage = percentage;
    }

    private function onBytesLoadedChange(e:LoadEvent):void {
      updateDownloadProgress(e.bytes);
    }

    private function onBytesTotalChange(e:LoadEvent):void {
      bytesTotal = e.bytes;
    }

    private function updateDownloadProgress(bytesLoaded:Number):void {
      if (bytesTotal > 0) {
        StateMonitor.Instance.SetDownloadedBytes(bytesLoaded);
        downloadProgressPercentage = bytesLoaded / bytesTotal;
      } else {
        downloadProgressPercentage = 0;
      }
 	  StateMonitor.Instance.StartSession();
   }

    private function onStateChange(event:MediaPlayerStateChangeEvent):void {
      logger.info('Media Player State Change: {0}', event.state);
      if (event.state == MediaPlayerState.PLAYING) {
        var loadTrait:LoadTrait = LoadTrait(((this.media as PseudoStreamingProxyElement).proxiedElement as VideoElement).getTrait(MediaTraitType.LOAD));
        EventBus.dispatch(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE, false, false, null, loadTrait.bytesTotal));
      }
    }

    private function onDurationChange(e:TimeEvent):void {
      if (e.time && e.time != 0 && !durationCached) {
        duration = e.time;
        durationCached = true;
        logger.info('Video duration cached.');
        EventBus.dispatch(new PlayerEvent(PlayerEvent.DURATION_CHANGE, duration));
      }
    }

    private function onPlayaheadTimeChanged(e:PlayerEvent):void {
      playaheadTime = e.data;
    }

    private function onError(e:ErrorEvent):void {
      fadeOut();
    }

    private function calculatedSeekPositionGivenPercentage(seekPercentage:Number):Number {
      return seekPercentage * duration;
    }

    public function hasVideoLoaded():Boolean {
      return this.media != null;
    }

    public function fadeIn():void {
      Tweener.addTween(this, { time: 2, alpha: 1, onStart: show });
    }

    public function fadeOut():void {
      Tweener.addTween(this, { time: 2, alpha: 0, onComplete: hide });
    }

    public function show():void {
      visible = true;
    }

    public function hide():void {
      visible = false;
      alpha = 0;
    }

    private function setupMediaPlayer():void {
      this.mediaPlayer.autoPlay = Configuration.getInstance().autoPlay;
    }

    private function setupInterface():void {
      this.scaleMode = ScaleMode.LETTERBOX;
      resize();
    }

    public function resize(newWidth:Number = 320, newHeight:Number = 240):void {
      if (stage != null) {
        this.width = newWidth;
        this.height = newHeight;
      }
    }

    public function setSize(newWidth:Number = 320, newHeight:Number = 240):void{
      this.width = newWidth;
      this.height = newHeight;
    }

    private function setupBusDispatchers():void {
      this.mediaPlayer.addEventListener(TimeEvent.COMPLETE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, EventBus.dispatch);
      this.mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
    }
	
	/**
	 *Adicionando listeners dos eventos. 
	 * 
	 */
    private function setupBusListeners():void {
      EventBus.addListener(PlayerEvent.LOAD, onLoad);
      EventBus.addListener(PlayerEvent.PLAY, onPlay);
      EventBus.addListener(PlayerEvent.PAUSE, onPause);
      EventBus.addListener(PlayerEvent.STOP, onStop);

      EventBus.addListener(TimeEvent.COMPLETE, onVideoEnded);
      EventBus.addListener(TimeEvent.DURATION_CHANGE, onDurationChange);
      EventBus.addListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
      EventBus.addListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);

      EventBus.addListener(PlayerEvent.VOLUME_CHANGE, onVolumeChange);
      EventBus.addListener(PlayerEvent.MUTE, onMute);
      EventBus.addListener(PlayerEvent.UNMUTE, onUnmute);

      EventBus.addListener(PlayerEvent.SEEK, onSeek);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, onTopicsSeek);
      EventBus.addListener(PlayerEvent.PLAYAHEAD_TIME_CHANGED, onPlayaheadTimeChanged);

      EventBus.addListener(ErrorEvent.ERROR, onError);
      EventBus.addListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
      EventBus.addListener(SlideEvent.SLIDE_CHANGED, onSlideChanged, EventBus.INPUT);
      EventBus.addListener(SlideEvent.SLIDE_SYNC_CHANGED, onSlideSyncChanged, EventBus.INPUT);
    }
  }
}
