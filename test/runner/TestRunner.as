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

package runner {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.TextEvent;
  import flash.system.fscommand;
  
  import org.flexunit.internals.TraceListener;
  import org.flexunit.runner.FlexUnitCore;
  import org.flexunit.runner.notification.async.AsyncListenerWatcher;
  
  import suite.TestSuite;
  
  public class TestRunner extends Sprite {
    private var flexUnitCore:FlexUnitCore = new FlexUnitCore();
    private var failureCheckerListener:FailureCheckerListener = new FailureCheckerListener();
    private var testNotifierListener:TestNotifierListener = new TestNotifierListener();
    
    public function TestRunner() {
      setupEventListeners();
      connectToTestServer();
    }
    
    private function setupEventListeners():void {
      testNotifierListener.addEventListener(AsyncListenerWatcher.LISTENER_READY, onConnect);
      testNotifierListener.addEventListener(AsyncListenerWatcher.LISTENER_FAILED, onListenerError);
      
      flexUnitCore.addEventListener(FlexUnitCore.TESTS_COMPLETE, onComplete);
    }
    
    private function connectToTestServer():void {
      testNotifierListener.connect();
    }
    
    private function addListeners():void {
      flexUnitCore.addListener(testNotifierListener);
      flexUnitCore.addListener(new TraceListener());
    }
    
    private function runTests():void {
      flexUnitCore.run(currentRunTestSuite());
    }
    
    private function currentRunTestSuite():Array {
      var testsToRun:Array = new Array();
      testsToRun.push(TestSuite);
      return testsToRun;
    }
    
    private function onConnect(e:Event):void {
      trace("Connected to test server, starting tests...");
      addListeners();
      runTests();
    }
    
    private function onListenerError(e:TextEvent):void {
      trace("Can't connect to test server. Details: " + e.text);
      fscommand('quit');
    }
    
    private function onComplete(e:Event):void {
      trace("Test run completed, quitting.");
      fscommand('quit');
    }
  }
}