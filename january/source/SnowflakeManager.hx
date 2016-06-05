package;
import flixel.FlxG;
import snowflakes.Chord;
import snowflakes.Harmony;
import snowflakes.Octave;
import snowflakes.Small;
import snowflakes.Transpose;
import snowflakes.Vamp;

class SnowflakeManager
{

	/** Used to store Intervals.loadout */
	static var i:Map<String, String>;
	/** Whether to use primary or secondary timbre set. */
	static public var timbre:String= "";
	/** Volume Modifier for Secondary Timbre, used to divide original volume. */
	static public var _volumeMod:Float = 1.5;

	// Snowflake spawning probabilities
	private static var flakes:Array<Class<Snowflake>> 	= [Small, Octave, Harmony, Chord, Vamp, Transpose];
	public static var weights:Array<Float> 				= [88.5 , 3.5	, 3.5	 , 2	, 2	  , 0.5		 ];

	/** Determines which snowflakes to spawn.  */
	public static function manage():Void
	{
		var flakeID:Class<Snowflake> = flakes[FlxG.random.weightedPick(weights)];
		var flake:Snowflake = PlayState.snow.recycle(flakeID, null, true, true);
		var typeName:String = Type.getClassName(flakeID);
		typeName = StringTools.replace(typeName, "snowflakes.", "");
		flake.spawn(typeName);
	}
}