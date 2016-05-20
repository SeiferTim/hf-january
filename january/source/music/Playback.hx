package music;

class Playback
{

	/** The current gameplay mode. */
	public static var mode:String = "Write";
	/** Current playbackSequence of notes being cycled through */
	public static var sequence:Array<String> = [];		
	/** Current position in playbackSequence array */
	public static var index:Int = 0;
	/** Whether or not Playback mode is in reverse. */
	public static var reverse:Bool;
	/** The state of staccato mode. */
	public static var noteLength:String = "Full";

	/** Cycle through the playback modes. */
	public static function cycle(direction:String = "Left"):Void
	{
		if (direction == "Left")
		{
			if (mode == "Detour")
				repeat();
			else
				write();
		}
		if (direction == "Right")
		{
			if (mode == "Write")
				repeat();
			else
				detour();
		}
	}
	
	public static function write():Void
	{
		mode = "Write";
		sequence = [];
		index = 0;
		reverse = false;
		PlayState.feedback.show(mode);
	}
	
	public static function repeat():Void
	{
		mode = "Repeat";
		PlayState.feedback.show(mode);
	}
	
	public static function detour():Void
	{
		mode = "Detour";
		PlayState.feedback.show(mode);
	}
	
	/** Reset a sequence currently in writing, or restart a repeat sequence. */
	public static function resetRestart():Void
	{
		if (mode != "Detour")
		{
			if (mode == "Write")
			{
				sequence = [];
				index = 0;
				PlayState.feedback.show("Reset");
			}
			else
			{
				index = 0;	
				PlayState.feedback.show("Restart");
			}	
		}
	}
	
	/** Reverse the note order of repeat sequence. */
	public static function polarity():Void
	{
		if (mode == "Repeat")
		{			
			reverse = !reverse;
			
			if (reverse == true)
			{
				index -= 2;
				if (index < 0)
					index = index + sequence.length;
				
				PlayState.feedback.show("Backwards");
			}
			else
			{
				index += 2;
				if (index > sequence.length - 1)
					index = index - sequence.length;
				
				PlayState.feedback.show("Forwards");
			}
		}
	}
	
	public static function staccato():Void
	{
		if (noteLength == "Full")
			noteLength = "Half";
		else if (noteLength == "Half")
			noteLength = "Random";
		else
			noteLength = "Full";
		
		PlayState.feedback.show("Note Length: " + noteLength);
	}
	
}