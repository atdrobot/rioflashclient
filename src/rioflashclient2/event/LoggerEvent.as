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
  import flash.events.Event;

  public class LoggerEvent extends Event {
    public static const LOGGER_EVENT:String = "loggerEvent";
    
    public var message:String;
    
    public function LoggerEvent(type:String, message:String=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
      super(type, bubbles, cancelable);
      
      this.message = message;
    } 
    
    public override function clone():Event {
      return new LoggerEvent(type, this.message, bubbles, cancelable);
    } 
    
    public override function toString():String {
      return formatToString("LoggerEvent", "type", "message", "bubbles", "cancelable", "eventPhase"); 
    }
  }
}
