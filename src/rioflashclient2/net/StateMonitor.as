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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import rioflashclient2.net.Messages.ActionMessage;
	import rioflashclient2.net.Messages.JumpActionMessage;
	import rioflashclient2.net.Messages.ResizeMessage;
	import rioflashclient2.net.Messages.SlideChangedMessage;
	import rioflashclient2.net.Messages.StartSessionMessage;
	import rioflashclient2.net.RemoteLogger;
	
	public class StateMonitor
	{
		private var xmlPath:String = "";
		// Slide Info
		private var slideNumber:Number = 0;
		private var slideSync:Boolean = true;
		private var slides:Array;
		// Topic info
		private var topicIndex:Number = 0;
		private var topicTime:Number = 0;
		private var topics:Array;
		// Target info
		private var targetTime:Number = -1;
		private var targetSlide:Number = -1;
		private var targetTopic:Number = -1;
		// General info
		private var state:String = "Unknown";
		private var downloadedBytes:Number = 0;
		private var time:Number = 0;
		private var playerMode:String = "REGULAR";
		private static const instance:StateMonitor = new StateMonitor();
		// Timer
		private var updateTimer:Timer;

		public function StateMonitor()
		{
			if ( instance != null )
			{ 
				throw new Error( "Please use the instance property to access." );
			}
			this.updateTimer = new Timer(30000);
			updateTimer.addEventListener(TimerEvent.TIMER, timerTriggered);
			updateTimer.start();
		}

		public static function get Instance():StateMonitor
		{
			return instance;
		}
		
		public function SetSlideInfo(slideNumber:Number):void
		{
			this.slideNumber = slideNumber + 1;
		}
		
		public function SetDownloadedBytes(downloadedBytes:Number):void
		{
			this.downloadedBytes = downloadedBytes;
		}
		
		public function SetTopicInfo(topicIndex:Number, topicTime:Number):void
		{
			this.topicIndex = topicIndex + 1;
			this.topicTime = topicTime;
		}
		
		public function SetSlideSync(slideSync:Boolean):void
		{
			this.slideSync = slideSync;
			if (RemoteLogger.Instance.HasInitialized)
			{
				RemoteLogger.Instance.Log(new ActionMessage("SYNC", this.state, this.time, this.downloadedBytes,
					this.slideNumber, this.topicIndex, this.topicTime, this.slideSync, this.playerMode));
			}
		}
		
		public function SetState(state:String):void
		{
			this.state = state;
			if (RemoteLogger.Instance.HasInitialized)
			{
			    RemoteLogger.Instance.Log(new ActionMessage(this.state, this.state, this.time, this.downloadedBytes,
				    this.slideNumber, this.topicIndex, this.topicTime, this.slideSync, this.playerMode));
			}
		}
		
		public function Jump(state:String, targetTime:Number):void
		{
			if (RemoteLogger.Instance.HasInitialized)
			{
				this.setTargetsByTime(targetTime);
			    RemoteLogger.Instance.Log(new JumpActionMessage(state, this.state, this.time, this.downloadedBytes,
				    this.slideNumber, this.topicIndex, this.topicTime, this.slideSync, this.playerMode,
					targetTime, this.targetSlide, this.targetTopic));
			}
		}
		
		public function Resize():void
		{
			if (RemoteLogger.Instance.HasInitialized)
			{
		    	RemoteLogger.Instance.Log(new ActionMessage("RESIZE", this.state, this.time, this.downloadedBytes,
					this.slideNumber, this.topicIndex, this.topicTime, this.slideSync, this.playerMode));
			}
		}
		
		public function SlideChanged(targetSlide:Number, slideButton:String):void
		{
			if (RemoteLogger.Instance.HasInitialized)
			{
				this.setTargetsBySlide(targetSlide);
				RemoteLogger.Instance.Log(new SlideChangedMessage(this.state, this.time, this.downloadedBytes,
					this.slideNumber, this.topicIndex, this.topicTime, this.slideSync, this.targetTime, targetSlide + 1,
					this.targetTopic, slideButton, this.playerMode));
			}
		}

		public function SetPlayerMode(playerMode:String):void
		{
			this.playerMode = playerMode;
			if (RemoteLogger.Instance.HasInitialized)
			{
				RemoteLogger.Instance.Log(new ActionMessage("PLAYER_MODE_CHANGED", this.state, this.time, this.downloadedBytes,
					this.slideNumber, this.topicIndex, this.topicTime, this.slideSync, this.playerMode));
			}
		}
		
		public function SetSlides(slides:Array):void
		{
			this.slides = slides;
		}
		
		public function SetTime(time:Number):void
		{
			this.time = time;
		}
		
		public function SetTopics(topics:Array):void
		{
			this.topics = topics;
		}
		
		public function SetXmlPath(xmlPath:String):void
		{
			this.xmlPath = xmlPath;
		}
		
		public function StartSession():void
		{
			// FIXME: How to get rioclient version?
			if (!RemoteLogger.Instance.HasInitialized)
			{
			    RemoteLogger.Instance.Log(new StartSessionMessage(this.xmlPath, "1.0"));
			}
		}
		
		public function timerTriggered(event:TimerEvent):void
		{
			if (this.hasStarted())
			{
			    RemoteLogger.Instance.Log(new ActionMessage("STATE", this.state, this.time, this.downloadedBytes,
				                                        this.slideNumber, this.topicIndex, this.topicTime, this.slideSync, this.playerMode));
			}
		}
		
		private function hasStarted():Boolean
		{
			var started:Boolean = false;
			if (this.xmlPath != "" && RemoteLogger.Instance.HasInitialized)
			{
				started = true;
			}
			
			return started;
		}
		
		private function setTargetsByTime(targetTime:Number):void
		{
			if (this.slideSync)
			{
				this.targetSlide = 0;
				for (var i:uint = 0; i < this.slides.length; i++)
				{
					if (targetTime < this.slides[i].time)
					{
						break;
					}
				}
				this.targetSlide = i;

				this.targetTopic = 0;
				for (var j:uint = 0; j < this.topics.length; j++)
				{
					if (targetTime < this.topics[j])
					{
						break;
					}
				}
				this.targetTopic = j;
			}
			else
			{
				this.targetSlide = -1;
				this.targetTime = -1;
				this.targetTopic = -1;
			}
		}
		
		private function setTargetsBySlide(slideNumber:Number):void
		{
			if (this.slideSync)
			{
				this.targetTime = this.slides[slideNumber].time;
				this.targetTopic = 0;
				for (var j:uint = 0; j < this.topics.length; j++)
				{
					if (this.targetTime < this.topics[j])
					{
						break;
					}
				}
				this.targetTopic = j;
				this.targetSlide = slideNumber + 1;
			}
			else
			{
				this.targetSlide = -1;
				this.targetTime = -1;
				this.targetTopic = -1;
			}
		}
	}
}
