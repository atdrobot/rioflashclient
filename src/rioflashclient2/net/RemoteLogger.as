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
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class RemoteLogger
	{
		private const RemoteSite:String = "http://edad.rnp.br/";
		private const RemotePage:String = "index.html";
		private const ActionStringPrefix:String = RemoteSite + RemotePage + "?";
		
		private var urlLoader:URLLoader = new URLLoader();
		private static const instance:RemoteLogger = new RemoteLogger();

		public function RemoteLogger()
		{
			if ( instance != null )
			{ 
				throw new Error( "Please use the instance property to access." );
			}
			
			// set the loaders listener function that gets the event  
			this.urlLoader.addEventListener(Event.COMPLETE, urlLoaderComplete);  
			this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderComplete);
			this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderComplete);
		}
		
		public static function get Instance():RemoteLogger
		{
			return instance;
		}
		
		public function Action(action:String):void
		{
			this.urlLoader.load( new URLRequest(ActionStringPrefix + action));
		}

		private function urlLoaderComplete(evt:Event):void
		{
		}
	}
}
