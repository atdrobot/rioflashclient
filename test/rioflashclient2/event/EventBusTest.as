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
  
  import rioflashclient2.event.EventBus;
  import flash.events.Event;
  import org.flexunit.Assert;
  import org.flexunit.async.Async;
  
  public class EventBusTest {
    
    private var some_event:String;
    private var some_func:Function;
    
    [Before]
    public function setUp():void {
      some_event = "some_event";
      some_func = function():void {};
    }
    
    [Test]
    public function shouldAddListener():void {
      EventBus.addListener(some_event, some_func);
      
      Assert.assertTrue(EventBus.getInstance().hasEventListener(some_event));
    }
    
    [Test(async, timeout="3000")]
    public function shouldDispatchEvent():void {
      Async.proceedOnEvent(this, EventBus.getInstance(), some_event);
      
      EventBus.dispatch(new Event(some_event));
    }
    
  }
}