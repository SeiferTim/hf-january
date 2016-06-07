package music;

class Pedal
{
	/** Whether or not we're in Pedal Point Mode. */
	public static var mode:Bool = false;

	public static function toggle():Void {

		mode = !mode;
		PlayState.txtOptions.show("Pedal Point " + (mode ? "On" : "Off"));
	}
}