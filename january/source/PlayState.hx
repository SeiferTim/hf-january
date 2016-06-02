package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxTimer;
import music.Key;
import music.MIDI;
import music.Mode;
import music.Note;
import music.Pedal;
import music.Playback;
import music.Scale;
import openfl.Assets;
import openfl.utils.Object;


typedef SoundDef = {
	name:String,
	note:FlxSound
}

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
	public static var snow:FlxTypedGroup<Snowflake>;		// all of the snowflakes

	/* TEXT RELATED */
	public static var feedback:Text;		// the feedback text for secret features

	/* TIME-RELATED */
	public static inline var BLIZZARD:Int = 50;		// the minimum amount of time allowed between snowflake spawns
	private static inline var SHOWER:Int = 250;		// the initial spawn rate for snowflakes
	private static inline var FLURRY:Int = 1000;	// the slowest spawn rate
	public static var spawnRate:Int = SHOWER;		// the amount of time between snowflake spawns
	private static inline var SPAWNRATE_DECREMENTER:Int = 5;	// rate at which the time between snowflake spawns is decremented by
	private static var spawnTimer:Float = 0;			// the timer for determining when to spawn snowflakes

	public static var flamTimer:Float = 0;			// the timer used to create separation between notes
	public static var flamNotes:Array<SoundDef> = [];			// the notes to be flammed at any given time
	public static var flamRate:Int = 25;			// the time between flammed notes
	private static var flamCounter:Int = 0;			// used to count through the notes in a chord/etc to be flammed
	public static var sounds:Array<SoundDef> = [];

	public static var onAutoPilot:Bool = false;		// whether or not game is on autopilot or not
	public static var autoPilotMovement:String = "Right";
	public static var inImprovMode:Bool = false;	// whether or not game is in improv mode

	/** Initialize game, create and add everything. */
	override public function create():Void
	{
		Reg.score = SCORE_INIT;
		FlxG.sound.volume = 1;
		#if flash
		FlxG.sound.playMusic(AssetPaths.ambience__mp3, 1.0);
		#else
		FlxG.sound.playMusic(AssetPaths.ambience__ogg, 1.0);
		#end
		FlxG.sound.music.fadeIn(2,0,0.1);

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
		snow = new FlxTypedGroup<Snowflake>(1000);
		add(snow);

		// Add HUD
		HUD.init();
		add(HUD.row1);
		add(HUD.row2);
		add(HUD.row3);

		add(HUD.midiButton);

		add(HUD.promptBack);
		add(HUD.promptText);

		// Start Timers
		spawnTimer = 0;

		flamTimer = flamRate/1000;

		// Set Initial Mode to Ionian or Aeolian.
		Mode.index = FlxG.random.getObject([0, 4]);
		Mode.init();


		super.create();
	}

	static public function playSound(Sound:String, Volume:Float, Pan:Float):SoundDef
	{
		var note:FlxSound = FlxG.sound.play(Assets.getSound(getFilename(Sound)), Volume, false);
		note.pan = Pan;
		var s:SoundDef = {name: Sound, note: note };
		sounds.push({name: Sound, note: note });
		return s;
	}

	static public function getFilename(Sound:String):String
	{
		var filename:String = "notes/" + StringTools.replace(Sound, "_", "U");
		#if flash
		filename+= ".mp3";
		#else
		filename+= ".ogg";
		#end
		return filename;
	}

	static public function loadSound(Sound:String, Volume:Float, Pan:Float):SoundDef
	{
		if (StringTools.endsWith(Sound, "null"))
			return null;
		var note:FlxSound = FlxG.sound.load(Assets.getSound(getFilename(Sound)), Volume, false);
		note.pan = Pan;
		var s:SoundDef = {name: Sound, note: note };
		sounds.push({name: Sound, note: note });
		return s;
	}

	/** Called every frame. */
	override public function update(elapsed:Float):Void
	{
		// Timer callback, used to flam out notes in chords, etc. Awesome!
		flamTimer -= elapsed;
		if (flamTimer <= 0 && flamTimer > -100)
		{
			if (flamNotes[0] != null && flamCounter <= flamNotes.length - 1)
			{
				var flamNote:SoundDef = flamNotes[flamCounter];

				flamNote.note.play();

				var classToLog:String = "";
				var volToLog:Float = 0;

				// Always pass the primary timbre to the MIDI logging system.
				if (flamNote.name.substr(0,1) == "_")
				{
					classToLog = flamNote.name.substr(1);
					volToLog = flamNote.note.volume * SnowflakeManager._volumeMod;
				}
				else
				{
					classToLog = flamNote.name;
					volToLog = flamNote.note.volume;
				}

				MIDI.log(classToLog, volToLog);
				flamCounter++;
				flamTimer = flamRate / 1000;
			}
			else
			{
				flamRate = FlxG.random.int(25, 75);		// Fluctuate the arpeggio rate.
				flamCounter = 0;
				flamNotes = [];
				flamTimer = -100;
			}
		}

		spawnTimer -= elapsed;
		if (spawnTimer <= 0)
		{
			if (spawnRate <= BLIZZARD)
				spawnRate = BLIZZARD;

			spawnTimer = spawnRate / 1000;
			SnowflakeManager.manage();

			if (onAutoPilot)
			{
				if (player.tongueUp)
				{
					if (FlxG.random.bool(2))
						player.tongueUp = !player.tongueUp;
				}
				else
				{
					if (FlxG.random.bool(10))
							player.tongueUp = true;
				}

				if (FlxG.random.bool(2))
					autoPilotMovement = FlxG.random.getObject(["Left", "Right", "Still"]);
			}
		}

		super.update(elapsed );

		// Loop Sky Background
		if (sky.x < -716) sky.x = 0;

		if (HUD.promptText.exists)
		{
			#if !flash
			if (FlxG.keys.justPressed.Y)		Sys.exit(0);
			else if (FlxG.keys.justPressed.N)	HUD.hideExit();
			#end
		}
		else
		{
			// Collision Check
			if (player.tongueUp) FlxG.overlap(snow, player, onLick);

			// Key input checks for advanced features!.
			if (FlxG.keys.justPressed.PLUS)			moreSnow();
			if (FlxG.keys.justPressed.MINUS)		lessSnow();

			if (FlxG.keys.justPressed.K)			Key.cycle();
			if (FlxG.keys.justPressed.COMMA)		Mode.cycle("Left");
			if (FlxG.keys.justPressed.PERIOD)		Mode.cycle("Right");
			if (FlxG.keys.justPressed.SLASH) 		Scale.toPentatonic();
			if (FlxG.keys.justPressed.P) 			Pedal.toggle();

			if (FlxG.keys.justPressed.LBRACKET)		Playback.cycle("Left");
			if (FlxG.keys.justPressed.RBRACKET)		Playback.cycle("Right");
			if (FlxG.keys.justPressed.ENTER) 		Playback.polarity();
			if (FlxG.keys.justPressed.BACKSLASH)	Playback.resetRestart();

			if (FlxG.keys.justPressed.SHIFT)		Playback.staccato();
			if (FlxG.keys.justPressed.I)			improvise();
			if (FlxG.keys.justPressed.ZERO)			autoPilot();

			if (FlxG.keys.justPressed.H)			HUD.toggle();
			if (FlxG.keys.justPressed.M)			HUD.midi();

			#if !flash
			if (FlxG.keys.justPressed.F)			FlxG.fullscreen = !FlxG.fullscreen;
			if (FlxG.keys.justPressed.ESCAPE)		HUD.promptExit();
			#end
		}

		// Keep MIDI Timer in check, to get appropriate time values for logging.
		if (Note.lastAbsolute != null)
			MIDI.timer += elapsed;
		if (MIDI.logged == true)
		{
			MIDI.timer = 0;
			MIDI.logged = false;
		}
	}

	/**
	 * Called when the player's tongue is up, and hits a snowflake.
	 *
	 * @param SnowRef		The Snowflake licked.
	 * @param PlayerRef		The Player sprite.
	 *
	 */
	public function onLick(SnowRef:Snowflake, PlayerRef: Player):Void
	{
		SnowRef.onLick();

		if (Playback.mode == "Repeat")
			feedback.onLick(SnowRef);

		spawnRate -= SPAWNRATE_DECREMENTER;
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ADVANCED FEATURES /////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	private static function moreSnow():Void
	{
		if (spawnRate <= SHOWER)
		{
			spawnRate = BLIZZARD;
			feedback.show("Blizzard");
		}
		else
		{
			spawnRate = SHOWER;
			feedback.show("Shower");
		}
	}

	private static function lessSnow():Void
	{
		if (spawnRate < SHOWER)
		{
			spawnRate = SHOWER;
			feedback.show("Shower");
		}
		else
		{
			spawnRate = FLURRY;
			feedback.show("Flurry");
		}
	}

	private static function autoPilot():Void
	{
		onAutoPilot = !onAutoPilot;

		if (onAutoPilot)
		{
			feedback.show("Auto Pilot On");
			player.tongueUp = true;
		}
		else
		{
			feedback.show("Auto Pilot Off");
			player.tongueUp = false;
		}
	}

	private function improvise():Void
	{
		inImprovMode = !inImprovMode;

		if (inImprovMode)
			feedback.show("Improv Mode On");
		else
			feedback.show("Improv Mode Off");
	}
}
