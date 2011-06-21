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

package rioflashclient2.net.Messages
{
	import flash.system.Capabilities;
	import flash.external.ExternalInterface;

	public class StartSessionMessage extends Message
	{
		private var videoAula:String = "";
		private var browser:String = "";
		private var rioClientVersion:String = "";
		private var operatingSystem:String = "";
		
		public function StartSessionMessage(videoAula:String, rioClientVersion:String)
		{
			super(this);
			
			this.videoAula = videoAula;
			this.rioClientVersion = rioClientVersion;
			
			initializeConstants();
		}
		
		public override function toString():String
		{
			var message:String = super.toString()
				              + super.Separator + this.videoAula
			                  + super.Separator + this.browser
							  + super.Separator + this.rioClientVersion
							  + super.Separator + this.operatingSystem;
			return message;
		}
		
		private function initializeConstants():void
		{
			// Get operating system
			this.operatingSystem = flash.system.Capabilities.os;
			
			// browser detection
			try
			{
			    var v : String = flash.external.ExternalInterface.call("function(){return navigator.appVersion+'-'+navigator.appName;}");
			    this.browser = v;
			}
			catch (e:Error)
			{
				this.browser = "Unknown";
			}
		}
	}
}