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
  import rioflashclient2.event.EventBus;
  
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.HTTPStatusEvent;
  import flash.events.ProgressEvent;
  import flash.events.TextEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.utils.getQualifiedClassName;
  
  import org.osmf.logging.Log;
  import org.osmf.logging.Logger;
  
  public class GenericLoader {
    private var loader:URLLoader;
    
    protected var logger:Logger;
    
    public function GenericLoader() {
      this.logger = Log.getLogger(getClassName());
      this.loader = new URLLoader();
    }
    
    public function load():void {
      logger.info('Loading...');
      
      addLoadURLListeners();
      loader.load(createRequest());
    }
    
    protected function url():String {
      throw new Error('Must be implemented by subclasses');
    }
    
    protected function loaded(data:*):void {
      throw new Error('Must be implemented by subclasses');
    }
    
    protected function onLoad(e:Event):void {
      var loader:URLLoader = e.target as URLLoader;
      
      loaded(loader.data);
    }
    
    protected function onError(e:TextEvent):void {
      EventBus.dispatch(new ErrorEvent(ErrorEvent.ERROR, false, false, "Não foi possível se conectar ao servidor."));
    }
    
	/*
	 * Adiciona os eventos de tratamento de URL
	*/
    private function addLoadURLListeners():void {
	  loader.addEventListener(Event.COMPLETE, onLoad);
      loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
      loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
    }
    
    private function createRequest():URLRequest {
      var request:URLRequest = new URLRequest();
      request.url = this.url();
      return request;
    }
    
    private function getClassName():String {
      return getQualifiedClassName(this).split('::')[1];
    }
  }
}