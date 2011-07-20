package rioflashclient2.net.Messages
{
	public class SlideChangedMessage extends JumpActionMessage
	{
		private var targetSlide:Number = -1;
		private var slideButton:String = "";
		
		public function SlideChangedMessage(state:String, currentTime:Number, downloadedBytes:Number, slide:Number,
											topic:Number, topicTime:Number, sync:Boolean, targetTime:Number, targetSlide:Number, 
											targetTopic:Number, slideButton:String, playMode:String)
		{
			super("SLIDE_CHANGED", state, currentTime, downloadedBytes, slide, topic, topicTime, sync, playMode, targetTime, targetSlide, targetTopic);
			this.targetSlide = targetSlide;
			this.slideButton = slideButton;
		}
		
		public override function toString():String
		{
			var message:String = super.toString() + super.Separator + this.targetSlide;
			message += super.Separator + this.slideButton;

			return message;
		}
	}
}