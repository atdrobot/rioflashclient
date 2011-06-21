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
	public class JumpActionMessage extends ActionMessage
	{
		private var targetTime:Number = -1;
		private var targetSlide:Number = -1;
		private var targetTopic:Number = -1;
		
		public function JumpActionMessage(action:String, state:String, currentTime:Number, downloadedBytes:Number, slide:Number,
										  topic:Number, topicTime:Number, sync:Boolean, playMode:String, targetTime:Number,
		                                  targetSlide:Number, targetTopic:Number)
		{
			super(action, state, currentTime, downloadedBytes, slide, topic, topicTime, sync, playMode);
			this.targetTime = targetTime;
			this.targetSlide = targetSlide;
			this.targetTopic = targetTopic;
		}
		
		public override function toString():String
		{
			var message:String = super.toString() + super.Separator;
			message += this.targetTime.toString() + super.Separator + this.targetSlide.toString()
				    + super.Separator + this.targetTopic.toString();
			return message;
		}
	}
}