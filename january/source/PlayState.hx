package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxTimer;
import music.MIDI;
import openfl.Assets;
import openfl.utils.Object;

class PlayState extends FlxState
{
	
	/* SCORE RELATED */
	private static inline var SCORE_INIT:Int = 0; 		// Initial Score
	public static var scores:Map<String, Int> = [
		"Chord" => 0, 
		"Harmony" => 0, 
		"Octave" => 0, 
		"Transpose" => 0, 
		"Vamp" => 0 
	]; 												// Scores of various snowflakes
	public static var mostLickedScore:Int = 0; 		// the highest flake score
	public static var mostLickedType:String = ""; 		// the type of flake licked most
	
	/* TILEMAPS */
	public static var ground:FlxTilemap; 		// tilemap of ground tiles
	private static var trees:FlxTilemap;		// tilemap of tree tiles
	private static var backtrees:FlxTilemap;	// tilemap of trees in the far distance
	
	/* SPRITES */
	private static var sky:FlxSprite;		// sprite of the sky
	private static var mountain:FlxSprite;	// sprite of the distant mountain
	public static var player:Player;		// the player sprite
	public static var snow:FlxGroup;		// all of the snowflakes
	
	/* TEXT RELATED */
	public static var feedback:Text;		// the feedback text for secret features
	
	/* TIME-RELATED */
	public static inline var BLIZZARD:Int = 50;		// the minimum amount of time allowed between snowflake spawns
	private static inline var SHOWER:Int = 250;		// the initial spawn rate for snowflakes
	private static inline var FLURRY:Int = 1000;	// the slowest spawn rate
	public static var spawnRate:Int = SHOWER;		// the amount of time between snowflake spawns
	private static inline var SPAWNRATE_DECREMENTER:Int = 5;	// rate at which the time between snowflake spawns is decremented by
	private static var spawnTimer:FlxTimer;			// the timer for determining when to spawn snowflakes
	
	public static var flamTimer:FlxTimer;			// the timer used to create separation between notes
	public static var flamNotes:Array<Dynamic> = [];			// the notes to be flammed at any given time
	private static var flamRate:Int = 25;			// the time between flammed notes
	private static var flamCounter:Int = 0;			// used to count through the notes in a chord/etc to be flammed
	
	public static var onAutoPilot:Bool = false;		// whether or not game is on autopilot or not
	public static var autoPilotMOvement:String = "Right";
	public static var inImprovMode:Bool = false;	// whether or not game is in improv mode
	
	/** Initialize game, create and add everything. */
	override public function create():Void
	{
		Reg.score = SCORE_INIT;
		FlxG.sound.volume = 1;
		#if flash
		FlxG.sound.playMusic(AssetPaths.ambience__mp3, 1 / 5);
		#else
		FlxG.sound.playMusic(AssetPaths.ambience__ogg, 1 / 5);
		#end
		FlxG.sound.music.fadeIn(2);
		
		// Set Channel 1 Instrument to Guitar
		MIDI.trackEvents.push(0);
		MIDI.trackEvents.push(193);
		MIDI.trackEvents.push(24);
		
		// Build World
		sky = new FlxSprite(AssetPaths.sky__png);
		sky.scrollFactor.x = 0;
		sky.velocity.x = -2;
		add(sky);
		
		mountain = new FlxSprite(FlxG.width - 70, 72, AssetPaths.hills__png);
		add(mountain);
		
		backtrees = new FlxTilemap();
		backtrees.y = 89;
		backtrees.loadMapFromCSV(Assets.getText("data/backtrees.txt"), AssetPaths.backtrees__png, 13, 7);
		add(backtrees);
		
		ground = new FlxTilemap();
		ground.loadMapFromCSV(Assets.getText("data/level.txt"), AssetPaths.ground__png, 16);
		ground.x = 0;
		add(ground);
		
		trees = new FlxTilemap();
		trees.y = 83;
		trees.scrollFactor.x = 0.25;
		trees.loadMapFromCSV(Assets.getText("data/trees.txt"), AssetPaths.trees__png, 51, 13);
		add(trees);
		
		//	Set World Bounds, for optimization purposes.
		FlxG.worldBounds.x = 0;
		FlxG.worldBounds.width = FlxG.width;
		FlxG.worldBounds.y = 78;
		FlxG.worldBounds.height = FlxG.height - FlxG.worldBounds.y;	
		
		// Add Feedback Text
		feedback = new Text(); 
		add(feedback);
		
		// Draw Player
		player = new Player(); 
		add(player);
		
		// Create Snow
		snow = new FlxGroup(); 
		add(snow);
		
		// Add HUD
		HUD.init(); 
		add(HUD.row1); 
		add(HUD.row2); 
		add(HUD.row3);
		
		add(HUD.midiButton);
		
		// Start Timers
		spawnTimer = new FlxTimer();
		spawnTimer.start(0);
		
		flamTimer = new FlxTimer();
		flamTimer.start(flamRate);
		
		// Set Initial Mode to Ionian or Aeolian.
		Mode.index = FlxG.random.getObject([0, 4]);
		Mode.init();
		
		
		super.create();
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
