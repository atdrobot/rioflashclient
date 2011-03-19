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

﻿package rioflashclient2.event {
  import rioflashclient2.model.Lesson;
  
  import flash.events.Event;

  public class LessonEvent extends Event {
    static public const LOADED             :String = "Lesson Loaded"
    static public const RESOURCES_LOADED   :String = "Lesson Resources Loaded"
    static public const RELOADED           :String = "Lesson Reloaded"
    
    public var lesson:Lesson;
    
    public function LessonEvent(type:String, lesson:Lesson=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
      super(type, bubbles, cancelable);
      
      this.lesson = lesson;
    } 
    
    public override function clone():Event {
      return new LessonEvent(type, this.lesson, bubbles, cancelable);
    }
    
    public override function toString():String {
      return formatToString("LessonEvent", "type", "lesson", "bubbles", "cancelable", "eventPhase"); 
    }
  }
}
