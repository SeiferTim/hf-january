package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.text.FlxText;
import music.Playback;
import music.Note;
import music.Pedal;

class Text extends FlxText
{

	// [Embed(source="../assets/frucade.ttf", fontFamily="frucade", embedAsCFF="false")] public static var font:String;

	/** The number of seconds to hold the text before it starts to fade. */
	private static var lifespan: Float = 0;

	/** The gutter size, used to keep text off screen edges. */
	public static inline var GUTTER: Int = 5;

	public function new()
	{
		x = -15;
		y = -15;

		super(x, y, 0);
		moves = true;
		velocity.y = -8;
		font = AssetPaths.frucade__ttf;
		alpha = 0;

	}

	/**
	 * onLick() - Figures out what text to display next, and where to display it so it looks nice.
	 *
	 * @param flakeType
	 *
	 */
	public function onLick(SnowRef: Snowflake):Void
	{
		var _text:String = "";

		// Store the number of the current place in the playback sequence when appropriate.
		if (SnowRef.playsNote) {

			if (Playback.mode == "Repeat") {

				if (Playback.reverse == false) {

					if (Playback.index != 0)
						_text = Std.string(Playback.index);
					else
						_text = Std.string(Playback.sequence.length);
				}
				else {

					var indexString: Int = Playback.index + 2;

					if (indexString == Playback.sequence.length + 1)
						_text = "1";
					else
						_text = Std.string(indexString);
				}
			}
			else {

				if (PlayState.inSpellMode) {

					_text = Std.string(HUD.enharmonic(SnowRef.noteName, true));

					if (SnowRef.type == "Harmony")
						_text += "+" + Std.string(HUD.enharmonic(Note.lastHarmony, true));
					else if (SnowRef.type == "Octave")
						_text += "+" + Std.string(HUD.enharmonic(Note.lastOctave, true));

					if (Pedal.mode)
						_text += "/" + Std.string(HUD.enharmonic(Note.lastPedal, true));
				}
			}

		}
		else {

			if (PlayState.inSpellMode)
				_text = Std.string(HUD.modeName);
		}

		// Show the new text feedback.
		if (_text != "")
			show(_text);
	}

	public function show(newText: String, offset: Int = 7):Void
	{
		lifespan = 1;
		text = newText;
		alpha = 1;
		maxVelocity.y = 0;
		drag.y = 0;
		x = PlayState.player.x;
		y = PlayState.player.y - 10;

		if (PlayState.player.facing == FlxObject.LEFT)
		{
			x-= width;// + offset;

			// Check Bounds on Left Side
			if (PlayState.player.x - width < GUTTER)
				x = GUTTER;
		}
		else // facing == RIGHT
		{
			x += offset;

			// Check Bounds on Right Side
			if (PlayState.player.x + width > FlxG.width - GUTTER)
				x = FlxG.width - GUTTER - width;
		}
	}

	override public function update(elapsed:Float):Void
	{
		velocity.x = -1*(Math.cos(y / 4) * 8);
		maxVelocity.y = 20;
		drag.y = 5;
		acceleration.y -= drag.y;

		super.update(elapsed);

		if (lifespan > 0)
			lifespan -= elapsed;
		else
			alpha -= elapsed;

		if (alpha < 0)
			alpha = 0;
	}
}