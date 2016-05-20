package music;

class Pedal
{

	/** Whether or not we're in Pedal Point Mode. */
	public static var mode:Bool = false;
	
	public static function toggle():Void
	{
		mode = !mode;
			
		if (mode == true)
			PlayState.feedback.show("Pedal Point: On");
		else
			PlayState.feedback.show("Pedal Point: Off");
	}
}