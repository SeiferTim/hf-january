package snowflakes;
import flixel.FlxG;
import music.Mode;
import music.Note;

class Chord extends Snowflake
{
		
	/** Default volume level for Chord Tones. */
	public static var VOLUME:Float = Note.MAX_VOLUME * 0.4;
	
	public function new()
	{
		super();
		
		loadGraphic(AssetPaths.chord__png, true);
		
		windY = 16;
		
		animation.add("default", [0,1,2,3], 3, true);
		
		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);
	}
	
	public override function onLick():Void
	{
		super.onLick();
		
		Mode.change();
		playNote();
		playChord();
	}
	
	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		animation.play("default");
	}

}