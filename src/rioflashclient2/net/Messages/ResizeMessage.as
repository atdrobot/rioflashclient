package rioflashclient2.net.Messages
{
	public class ResizeMessage extends Message
	{
		public function ResizeMessage()
		{
			super(this);
		}

		public override function toString():String
		{
			var message:String = super.toString() + super.Separator + "RESIZE";
			return message;
		}
	}
}