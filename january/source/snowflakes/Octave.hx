package snowflakes;
import flixel.FlxG;
import flixel.system.FlxSound;
import music.Note;

class Octave extends Snowflake {

	/** Default volume level for the octave tone (not the default note). */
	public static var VOLUME:Float = Note.MAX_VOLUME * 0.33;
	/** The probability weight for spawning this flake type. */
	public static inline var WEIGHT:Float = 3.5;

	public function new()
	{
		super();

		loadGraphic(AssetPaths.octave__png);

		windY = 14;
		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);

		pedalAllowed = true;
		playsNote = true;
	}

	public override function onLick():Void
	{
		super.onLick();

		playNote();
		playOctave();
	}

	private function playOctave():Void
	{
		var octaveTone:String="";

		for (i in 0...Note.DATABASE.length)
		{
			if (Note.lastAbsolute == Note.DATABASE[i])
			{
				while (octaveTone == "" || octaveTone == null)
					octaveTone = Note.DATABASE[i + FlxG.random.getObject([12, -12])];

				break;
			}
		}

		var octave:PlayState.SoundDef;

		if (SnowflakeManager.timbre == "Primary")
		{
			octave = PlayState.loadSound(octaveTone, Octave.VOLUME, -1 * pan);

		}
		else
		{
			var modifiedNote:String = "_" + octaveTone;
			octave = PlayState.loadSound(modifiedNote, Octave.VOLUME / SnowflakeManager._volumeMod, -1 * pan);
		}
		PlayState.flamNotes.push(octave);
		PlayState.flamTimer = PlayState.flamRate / 1000;

		setFadeAmt(octave.note);

		// LOGS
		Note.lastOctave = octaveTone;
	}

}