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
   * Classe que define os eventos da classe SlidePlayer.
   * @author LAND
   * 
   */  
  public class SlideEvent extends Event {
    public static const NEXT_SLIDE         :String = "onNextSlide";
    public static const PREV_SLIDE         :String = "onPrevSlide";
    public static const LAST_SLIDE         :String = "onLastSlide";
    public static const FIRST_SLIDE        :String = "onFirstSlide";
    public static const SLIDE_CHANGED      :String = "onSlideChanged";
    public static const SLIDE_SYNC_CHANGED :String = "onSlideSyncChanged";

    public var slide:*;

    public function SlideEvent(type:String, slide:*=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      super(type, bubbles, cancelable);
      this.slide = slide;
    }

    public override function clone():Event {
      return new SlideEvent(type, this.slide, bubbles, cancelable);
    }

    public override function toString():String {
      return formatToString("SlideEvent", "type", "slide", "bubbles", "cancelable", "eventPhase");
    }
  }
}
