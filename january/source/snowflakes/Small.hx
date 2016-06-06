package snowflakes;
import flixel.FlxG;
import music.Key;
import music.Mode;
import music.Note;
import music.Pedal;
import music.Playback;
import music.Scale;

class Small extends Snowflake
{

	public function new() {

		super();

		makeGraphic(1, 1);

		windY = 10;
		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);

		pedalAllowed = true;
		playsNote = true;
	}

	public override function onLick():Void
	{
		super.onLick();
		playNote();
	}

}