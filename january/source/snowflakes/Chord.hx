package snowflakes;
import flixel.FlxG;

class Chord extends Snowflake
{
		
	/** Default volume level for Chord Tones. */
	public static inline var VOLUME:Float = Note.MAX_VOLUME * 0.4;
	
	public function Chord()
	{
		super();
		
		loadGraphic(AssetPaths.chord__png, true);
		
		windY = 16;
		
		animation.add("default", [0,1,2,3], 3, true);
		
		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);
	}
	
	public override function onLick():void
	{
		super.onLick();
		
		Mode.change();
		playNote();
		playChord();
	}
	
	public override function update():void
	{
		super.update();
		
		animation.play("default");
	}

}