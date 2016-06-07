package music;

class Playback
{

	/** The current gameplay mode. */
	public static var mode:String = "Write";
	/** Current playbackSequence of notes being cycled through */
	public static var sequence:Array<String> = [];
	/** Maximum length allowed for a playbackSequence */
	public static var MAX_SEQUENCE:Int = 64;
	/** Current position in playbackSequence array */
	public static var index:Int = 0;
	/** Whether or not Playback mode is in reverse. */
	public static var reverse:Bool;
	/** The ID for current Note Length. */
	public static var noteLengthID:Int = 0;
	/** The ID for current Attack Time. */
	public static var attackTimeID:Int = 0;
	/** The current attackTime amount. */
	public static var attackTime:Float = 0;
	/** The attackTime lengths. */
	public static var attackTimes:Array<Float> = [0, 0.5, 1, 2];
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

		PlayState.txtOptions.show(mode);
	}

	public static function repeat():Void
	{
		mode = "Repeat";
		PlayState.txtOptions.show(mode);
	}

	public static function detour():Void
	{
		mode = "Detour";
		PlayState.txtOptions.show(mode);
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
				PlayState.txtOptions.show("Reset");
			}
			else
			{
				index = 0;
				PlayState.txtOptions.show("Restart");
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

				PlayState.txtOptions.show("Backwards");
			}
			else
			{
				index += 2;
				if (index > sequence.length - 1)
					index = index - sequence.length;

				PlayState.txtOptions.show("Forwards");
			}
		}
	}

	public static function changeNoteLengths():Void {

		var options:Array<String> = ["Random", "Short", "Medium", "Full"];
		noteLengthID = (noteLengthID + 1) % options.length;
		PlayState.txtOptions.show("Note Length: " + options[noteLengthID]);
	}

	public static function changeAttackTimes():Void {

		var options:Array<String> = ["Fast", "Medium", "Slow", "Molasses"];
		attackTimeID = (attackTimeID + 1) % options.length;
		PlayState.txtOptions.show("Attack Time: " + options[attackTimeID]);

		if (attackTimeID != 0)
			noteLengthID = 3;

		attackTime = attackTimes[attackTimeID];
	}

}