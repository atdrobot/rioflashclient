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
  import rioflashclient2.configuration.Configuration;
  import rioflashclient2.event.EventBus;
  import rioflashclient2.event.LessonEvent;
  import rioflashclient2.logging.EventfulLoggerFactory;
  
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.net.URLLoader;
  
  import flexunit.framework.Assert;
  
  import org.flexunit.async.Async;
  import org.osmf.logging.Log;
  
  public class LessonLoaderTest {
    private var lessonXML:String;
    private var lessonLoader:LessonLoader;
    
    [Before]
    public function setUp():void {
      Log.loggerFactory = new EventfulLoggerFactory();
      lessonXML = 'palestra_nelson.xml';
      lessonLoader = new LessonLoader();
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchLessonEventLoadedToEventBusWhenLessonDataIsLoadedAndParsed():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), LessonEvent.LOADED);
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldPutLoadedLessonDataWithTheLessonLoadedEvent():void {
      var loaded:Function = function(e:LessonEvent, ...args):void {
        Assert.assertNotNull(e.lesson);
      };
      
      Async.handleEvent(this, EventBus.getInstance(), LessonEvent.LOADED, loaded);
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldNotDispatchLessonEventLoadedToEventBusWhenLessonDataCannotBeLoaded():void {
      Async.failOnEvent(this, EventBus.getInstance(), LessonEvent.LOADED);
      EventBus.getInstance().addEventListener(ErrorEvent.ERROR, function(e:Event):void {});
      lessonXML = 'inexistent_lesson_xml';
      lessonLoader = new LessonLoader();
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchErrorEventToEventBusWhenLessonDataCannotBeLoaded():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), ErrorEvent.ERROR);
      lessonXML = 'inexistent_lesson_xml';
      lessonLoader = new LessonLoader();
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldNotDispatchLessonEventLoadedToEventBusWhenLessonDataIsInvalid():void {
      Async.failOnEvent(this, EventBus.getInstance(), LessonEvent.LOADED);
      EventBus.getInstance().addEventListener(ErrorEvent.ERROR, function(e:Event):void {});
      lessonXML = 'invalid_lesson_xml';
      lessonLoader = new LessonLoader();
      lessonLoader.load();
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchErrorEventToEventBusWhenLessonDataIsInvalid():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), ErrorEvent.ERROR);
      lessonXML = 'invalid_lesson_xml';
      lessonLoader = new LessonLoader();
      lessonLoader.load();
    }
  }
}