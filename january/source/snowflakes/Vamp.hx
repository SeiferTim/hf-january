package snowflakes;
import flixel.FlxG;
import music.Note;

class Vamp extends Snowflake {

	public function new()
	{
		super();

		loadGraphic(AssetPaths.vamp__png, true, 5, 5);

		windY = 16;

		animation.add("default", [0,0,0,0,0,0,0,0,0,0,1,2,1], 12, true);

		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);
	}

	public override function onLick():Void
	{
		super.onLick();

		playChord();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		animation.play("default");
	}

}