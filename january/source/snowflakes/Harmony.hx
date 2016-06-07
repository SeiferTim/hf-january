package snowflakes;
import flixel.FlxG;
import flixel.system.FlxSound;
import music.Intervals;
import music.Note;
import openfl.utils.Object;


class Harmony extends Snowflake {

	/** Default volume level for the harmony tone (not the default note). */
	public static var VOLUME:Float = Note.MAX_VOLUME * 0.33;

	public function new()
	{
		super();

		loadGraphic(AssetPaths.harmony__png, true);

		windY = 13;
		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);

		animation.add("default", [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], 6, true);

		pedalAllowed = true;
		playsNote = true;
	}

	public override function onLick():Void
	{
		super.onLick();

		playNote();
		playHarmonyTone();
	}

	private function playHarmonyTone():Void
	{
		var harmonyTone:String;
		var choices:Array<String> = [];
		var i:Map<String, String> = Intervals.loadout;

			 if (Note.lastAbsolute == i.get("one1")) choices = [i.get("thr1"), i.get("fiv1"), i.get("thr2"), i.get("fiv2")];
		else if (Note.lastAbsolute == i.get("two1")) choices = [i.get("fiv1"), i.get("sev1"), i.get("fiv2")];
		else if (Note.lastAbsolute == i.get("thr1")) choices = [i.get("fiv1"), i.get("one2")];
		else if (Note.lastAbsolute == i.get("for1")) choices = [i.get("fiv1"), i.get("one2"), i.get("two2")];
		else if (Note.lastAbsolute == i.get("fiv1")) choices = [i.get("thr1"), i.get("sev1"), i.get("thr2")];
		else if (Note.lastAbsolute == i.get("six1")) choices = [i.get("one2"), i.get("thr2")];
		else if (Note.lastAbsolute == i.get("sev1")) choices = [i.get("thr1"), i.get("fiv1"), i.get("thr2")];
		else if (Note.lastAbsolute == i.get("one2")) choices = [i.get("fiv1"), i.get("thr2"), i.get("fiv2")];
		else if (Note.lastAbsolute == i.get("two2")) choices = [i.get("fiv1"), i.get("fiv2"), i.get("sev2")];
		else if (Note.lastAbsolute == i.get("thr2")) choices = [i.get("sev1"), i.get("one2"), i.get("fiv2"), i.get("sev2"), i.get("one3")];
		else if (Note.lastAbsolute == i.get("for2")) choices = [i.get("two2"), i.get("fiv2"), i.get("one3")];
		else if (Note.lastAbsolute == i.get("fiv2")) choices = [i.get("thr2"), i.get("sev2"), i.get("thr3")];
		else if (Note.lastAbsolute == i.get("six2")) choices = [i.get("one3"), i.get("thr3")];
		else if (Note.lastAbsolute == i.get("sev2")) choices = [i.get("thr2"), i.get("fiv2"), i.get("thr3")];
		else if (Note.lastAbsolute == i.get("one3")) choices = [i.get("thr2"), i.get("fiv2"), i.get("thr3"), i.get("fiv3")];
		else if (Note.lastAbsolute == i.get("two3")) choices = [i.get("fiv2"), i.get("sev2"), i.get("fiv3")];
		else if (Note.lastAbsolute == i.get("thr3")) choices = [i.get("sev2"), i.get("one3"), i.get("fiv3"), i.get("sev3"), i.get("one4")];
		else if (Note.lastAbsolute == i.get("for3")) choices = [i.get("two3"), i.get("fiv3"), i.get("one4")];
		else if (Note.lastAbsolute == i.get("fiv3")) choices = [i.get("thr3"), i.get("sev3"), i.get("one4")];
		else if (Note.lastAbsolute == i.get("six3")) choices = [i.get("thr3"), i.get("one4")];
		else if (Note.lastAbsolute == i.get("sev3")) choices = [i.get("thr3"), i.get("fiv3")];
		else if (Note.lastAbsolute == i.get("one4")) choices = [i.get("thr3"), i.get("fiv3")];
		else trace("lastAbsolute not available for Harmony");

		harmonyTone = FlxG.random.getObject(choices);

		var harmony:PlayState.SoundDef;

		if (SnowflakeManager.timbre == "Primary")
		{
			harmony = PlayState.loadSound(harmonyTone, Harmony.VOLUME, -1 * pan);


		}
		else
		{
			var modifiedHarmony:String = "_" + harmonyTone;
			harmony = PlayState.loadSound(modifiedHarmony, Harmony.VOLUME / SnowflakeManager._volumeMod, -1 * pan);

		}

		PlayState.flamNotes.push(harmony);
		PlayState.flamTimer = PlayState.flamRate / 1000;

		setFadeAmt(harmony.note);

		// LOGS
		Note.lastHarmony = harmonyTone;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		animation.play("default");
	}

}