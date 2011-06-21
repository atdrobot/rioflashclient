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
	import flash.errors.IllegalOperationError;
	
	public class Message
	{
		protected const Separator:String = "*"; 
		protected static var sessionId:String = "0";
		protected var timestamp:String = "0";
		
		public function Message(self:Message)
		{
			if( self != this )
			{
				throw new IllegalOperationError("Message can not be instantiated directly");
			}
		}
		
		public function resetTimestamp():void
		{
			this.timestamp = Message.getTimestamp();
		}
		
		public function toString():String
		{
			this.resetTimestamp();
			return Message.sessionId + this.Separator + this.timestamp;
		}
		
		public static function setSessionId():void
		{
			Message.sessionId = Message.getTimestamp();
		}
		
		protected static function getTimestamp():String
		{
			var curTime:Date = new Date();
			var curMonth:Number = curTime.getUTCMonth() + 1;
			var curMonthString:String = curMonth.toString();
			curMonthString = (curMonthString.length < 2) ? "0" + curMonthString : curMonthString;
			
			var curDayString:String = curTime.getUTCDate().toString();
			curDayString = (curDayString.length < 2) ? "0" + curDayString : curDayString;
			
			var curHourString:String = curTime.getHours().toString();
			curHourString = (curHourString.length < 2) ? "0" + curHourString : curHourString;

			var curMinString:String = curTime.getMinutes().toString();
			curMinString = (curMinString.length < 2) ? "0" + curMinString : curMinString;
			
			var curSecString:String = curTime.getSeconds().toString();
			curSecString = (curSecString.length < 2) ? "0" + curSecString : curSecString;

			var curMilString:String = curTime.getMilliseconds().toString();
			curMilString = (curMilString.length < 3) ? "00" + curMilString : curMilString;
			curMilString = (curMilString.length < 2) ? "0" + curMilString : curMilString;
			
			var timestamp:String = curTime.getFullYear().toString() + curMonthString + curDayString
				+ curHourString + curMinString + curSecString + curMilString;

			return timestamp;
		}
	}
}