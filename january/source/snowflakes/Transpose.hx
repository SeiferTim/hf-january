package snowflakes;
import flixel.FlxG;
import flixel.system.FlxSound;
import music.Intervals;
import music.Key;
import music.Mode;
import music.Note;

class Transpose extends Snowflake
{

	//[Embed(source="../assets/art/flakes/transpose.png")] private var sprite : Class;

	public function new()
	{
		super();

		loadGraphic(AssetPaths.transpose__png, true, 5, 6);

		windY = 15;

		animation.add("default", [0,1,2,3,4,3,2,1], 3, true);

		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);
	}

	public override function onLick():Void
	{
		super.onLick();

		Mode.change();
		Key.change();
		fadeOutDissonance();
		//playNote();
		playChord();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		animation.play("default");
	}

	private function fadeOutDissonance():Void
	{
		var sound:PlayState.SoundDef;
		var g:UInt = 0;

		var i:Map<String, String> = Intervals.loadout;

		// Run through all sounds.
		for (sound in PlayState.sounds)
		{
			var noteOk:Bool = false;

			// If the sound has volume,
			if (sound.note != null && sound.note.active == true)
			{
				// Compare to current key notes.
				for (note in i) {

					if (sound.name == note || sound.name == "_" + note) {

						noteOk = true;
						break;
					}
				}

				if (noteOk)
					continue;

				// If a note made it this far, it's not in the current key, so fade it out.
				sound.note.fadeOut(0.2);
			}
		}
	}
}