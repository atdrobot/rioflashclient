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
  import br.com.stimuli.loading.BulkLoader;
  import br.com.stimuli.loading.BulkProgressEvent;
  
  import flash.events.Event;
  import flash.net.getClassByAlias;
  
  import mx.utils.object_proxy;
  
  import org.flexunit.internals.namespaces.classInternal;
  import org.osmf.events.TimeEvent;
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;
  import rioflashclient2.event.PlayerEvent;
  import rioflashclient2.net.StateMonitor;

  public class Lesson {
    public var loader:BulkLoader;

    public var filename:String;
    public var filesize:String;
    public var title:String;
    public var type:String;
    public var professor:String;
    public var course:String;
    public var coursecode:String;
    public var grad_program:String;
    public var source:String;
    public var bitrate:String;
    public var duration:Number;
    public var resolution_x:String;
    public var resolution_y:String;
    public var index:String;
    public var sync:String;
    public var indexXML:XML;
    public var syncXML:XML;
    public var topics:Topics;
    public var slides:Array = new Array();
    private var _video:Video;

	protected var logger:Logger;

    public function Lesson() {
       // do nothing
	   logger = Log.getLogger('Lesson');
    }

    public function valid():Boolean {
      return hasVideo() && videoValid() && allSlidesValid();
    }

    public function videoValid():Boolean {
      return _video.valid();
    }

    public function video():Video {
      return _video;
    }

    public function hasVideo():Boolean {
      return video != null;
    }

    public function allSlidesValid():Boolean {
      return slides.every(function(slide:Slide, index:int, array:Array):Boolean {
        return slide.valid();
      });
    }
	
	public function getString( xmllist: XMLList ):String
	{
		var Indice:int = -1;
		if( xmllist == null )
			return "";
		for( var i:int = 0; i < xmllist.length(); i++ )
		{
			if( xmllist[ i ].attribute( "language" ) == 'pt-BR' )
			{
				Indice = i;
				break;
			}
		}
		if( Indice == -1 )
			return xmllist[ 0 ];
		else
			return xmllist[ Indice ];
	}

    public function parse(xml:XML):void {
	  var XmlType:String = xml.name().toString();
	  var VideoFileName:String;
	  if( XmlType == 'rio_object' )
	  {
          filename = xml.obj_filename;
		  logger.info( filename );
          filesize = xml.obj_filesize;
          title = xml.obj_title;
          type = xml.obj_type;
          professor = xml.professor;
          course = xml.course;
          coursecode = xml.coursecode;
          grad_program = xml.grad_program;
          source = xml.source;
          bitrate = xml.bitrate;
          duration = toNumber(xml.duration);
          resolution_x = xml.resolution.r_x
          resolution_y = xml.resolution.r_y
          index = xml.related_media.rm_item.(rm_type == 'index').rm_filename;
          sync = xml.related_media.rm_item.(rm_type == 'sync').rm_filename;
		  VideoFileName = xml.related_media.rm_item.(rm_type == 'video').rm_filename
	  }
	  else
	  {
		  var AuthorPattern:RegExp = /^.*FN:|END.*$/g;
		  var StrDurationPattern1:RegExp = /^PT|S$/g;
		  var StrDurationPattern2:RegExp = /H|M/g;
		  title = getString( xml.general.title.string ); 
		  type = "";
		  professor = xml.lifecycle.contribute.(role == 'author').entity[ 1 ];
		  if( professor == null )
		  {
			  professor = xml.lifecycle.contribute.(role == 'author').entity[ 0 ];
			  if ( professor == null )
				  professor = "";
		  }
		  professor = professor.replace( AuthorPattern, "" );
		  course = getString( xml.videoaula.educational.course.title.string );
		  coursecode = xml.videoaula.educational.course.code;
		  source = xml.lifecycle.contribute.(role == 'author').entity[ 0 ];
		  if( source == null )
		     source = "";
		  source = source.replace( AuthorPattern, "" );
		  grad_program = getString( xml.videoaula.program.string );
		  bitrate = xml.videoaula.technical.bitrate;
		  var StrDuration:String = xml.technical.duration;
		  StrDuration = StrDuration.replace( StrDurationPattern1, "" );
		  StrDuration = StrDuration.replace( StrDurationPattern2, ":" );
		  duration = toNumber( StrDuration );
          var resolution:String = xml.technical.platformspecificfeatures.specificstandardresolution;
		  if( ( resolution != null ) && ( resolution.lastIndexOf( "x" ) != -1 ) )
		  {
			  var Indice:int = resolution.lastIndexOf( "x" );
              resolution_x = resolution.substring( 0, Indice - 1 );
			  resolution_y = resolution.substring( Indice + 1 );
		  }
		  else
		  {
			  if( resolution != null )
				  logger.error( "Valor invalido " + resolution + " no campo de resolucao. Valor ignorado!" );  
			  resolution_x = "";
			  resolution_y = "";
		  }
		  index = xml.videoaula.technical.relatedmedia.(catalog == 'index').entry;
		  sync = xml.videoaula.technical.relatedmedia.(catalog == 'sync').entry;
		  VideoFileName = xml.videoaula.technical.relatedmedia.(catalog == 'video').entry
		  filename = VideoFileName;
		  filesize = xml.technical.size;
	  }
	  _video = new Video( VideoFileName );
	  
	  setupInputBusListeners();
    }

    public function toNumber(value:String):Number{
      var values:Array =  value.split(":");
      var newValue:Number = Number(values[0]) * 3600 + Number(values[1]) * 3600 + Number(values[2]);
      return newValue;
    }

    private function onInputPlay(e:PlayerEvent):void {
      video().play();
    }

    private function onInputPause(e:PlayerEvent):void {
      video().pause();
    }

    private function onInputStop(e:PlayerEvent):void {
      video().stop();
    }

    private function dispatchLoad():void {
      EventBus.dispatch(new PlayerEvent(PlayerEvent.LOAD, {lesson:this}));
      video().play();
      video().pause();
    }

    private function setupInputBusListeners():void {
      EventBus.addListener(PlayerEvent.PLAY, onInputPlay, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.PAUSE, onInputPause, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.STOP, onInputStop, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.STOP, onInputStop);

      EventBus.addListener(PlayerEvent.SEEK, EventBus.dispatch, EventBus.INPUT);
      EventBus.addListener(PlayerEvent.TOPICS_SEEK, EventBus.dispatch, EventBus.INPUT);
      EventBus.addListener(TimeEvent.CURRENT_TIME_CHANGE, EventBus.dispatch, EventBus.INPUT);
    }

    public function loadTopicsAndSlides():void {
      loader = new BulkLoader('index-sync-load');

      loader.add(Configuration.getInstance().resourceURL(this.sync), { id: "sync-xml" });
      loader.add(Configuration.getInstance().resourceURL(this.index), { id: "index-xml" });

      loader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);

      loader.start();
    }

    public function onAllItemsLoaded(evt : Event) : void {
      syncXML = new XML(loader.getText("sync-xml"));
      indexXML = new XML(loader.getText("index-xml"));

      for each (var slide:XML in syncXML.slide) {
        slides.push(Slide.createFromRaw(slide));
      }
	  StateMonitor.Instance.SetSlides(this.slides);
	  
      topics = new Topics(indexXML);

	  
      EventBus.dispatch(new LessonEvent(LessonEvent.RESOURCES_LOADED, this));
      dispatchLoad();
    }


  }
}