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

  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.TextEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;

  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;

  public class LessonLoader extends GenericLoader {

    public function LessonLoader() { }

    protected override function loaded(data:*):void {
      var lesson:Lesson = new Lesson();
      lesson.parse(new XML(data));
      lesson.loadTopicsAndSlides();

      if (lesson.valid()) {
        EventBus.dispatch(new LessonEvent(LessonEvent.LOADED, lesson));
        logger.info('Lesson loaded.');
      } else {
        EventBus.dispatch(new ErrorEvent(ErrorEvent.ERROR, false, false, 'Lesson is not valid.'));
        logger.error('Lesson is not valid.');
      }
    }

    protected override function url():String {
      return Configuration.getInstance().resourceURL(Configuration.getInstance().lessonXML);
    }
  }
}