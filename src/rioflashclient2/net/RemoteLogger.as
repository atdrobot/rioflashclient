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

package rioflashclient2.net
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import rioflashclient2.net.Messages.Message;

	public class RemoteLogger
	{
		private var RemoteSite:String = "http://edad.rnp.br/";
		private const RemotePage:String = "userlog.rio?logline=";
		private var ActionStringPrefix:String = RemoteSite + RemotePage;
		
		private var urlLoader:URLLoader = new URLLoader();
		private static const instance:RemoteLogger = new RemoteLogger();
		
		private var urlDebug:String = "";
		private var initialized:Boolean = false;

		public function RemoteLogger()
		{
			if ( instance != null )
			{ 
				throw new Error( "Please use the instance property to access." );
			}
			
			// set the loaders listener function that gets the event  
			this.urlLoader.addEventListener(Event.COMPLETE, urlLoaderComplete);  
			this.urlLoader.addEventListener(Event.OPEN, urlLoaderComplete);  
			this.urlLoader.addEventListener(flash.events.ProgressEvent.PROGRESS, urlLoaderComplete);
			this.urlLoader.addEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS, urlLoaderComplete);  
			this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderComplete);
			this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderComplete);
			// this.urlLoader.addEventListener(Event.*, urlLoaderComplete);
		}
		
		public static function get Instance():RemoteLogger
		{
			return instance;
		}
		
		public function Action(action:String):void
		{
			this.urlLoader.load( new URLRequest(ActionStringPrefix + action));
		}
		
		public function Log(message:Message):void
		{
			var url:String = ActionStringPrefix + message.toString();
			this.urlDebug = url;
			this.urlLoader.load( new URLRequest(url) );
		}
		
		public function get HasInitialized():Boolean
		{
			return this.initialized;
		}
		
		public function SetServer(server:String):void
		{
			this.RemoteSite = server + "/";
			this.ActionStringPrefix = this.RemoteSite + this.RemotePage;
		}

		private function urlLoaderComplete(evt:Event):void
		{
			this.initialized = true;
		}
	}
}
