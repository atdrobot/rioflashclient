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
	public class ActionMessage extends Message
	{
		private var action:String = "unknown";
		private var state:String = "unknown";
		private var videoCurrentTime:String = "0";
		private var downloadedBytesFromVideo:String = "0";
		private var slide:String = "unknown";
		private var topic:String = "0";
		private var topicTime:String = "0";
		protected var syncButton:String = "unknown";
		private var playMode:String = "unknown";
		
		public function ActionMessage(action:String, state:String, currentTime:Number, downloadedBytes:Number, slide:Number,
		                              topic:Number, topicTime:Number, sync:Boolean, playMode:String)
		{
			super(this);
			this.action = action;
			this.state = state;
			this.videoCurrentTime = currentTime.toString();
			this.downloadedBytesFromVideo = downloadedBytes.toString();
			this.slide = slide.toString();
			this.topic = topic.toString();
			this.topicTime = topicTime.toString();
			this.syncButton = sync.toString().toUpperCase();
			this.playMode = playMode;
		}
		
		public override function toString():String
		{
			var message:String = super.toString() + super.Separator + this.action
                               + super.Separator + this.state
				               + super.Separator + this.videoCurrentTime
				               + super.Separator + this.downloadedBytesFromVideo
							   + super.Separator + this.slide + super.Separator + this.topic
							   + super.Separator + this.topicTime + super.Separator + this.syncButton
							   + super.Separator + this.playMode;
			return message;
		}
	}
}