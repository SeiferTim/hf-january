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
import music.Tone;
import openfl.Assets;
import openfl.utils.Object;


typedef SoundDef = {
	name:String,
	note:Tone,
	toFadeIn:Bool,
	vol:Float
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
	public static var txtNumbers:Text;					// the feedback text for repeat numbers.
	public static var txtNoteNames:Text;				// the feedback text for note names.
	public static var txtScales:Text;					// the feedback text for scales (modes, keys, pentatonic, etc)
	public static var txtOptions:Text;					// the feedback text for options (gameplay modes, weather, note length, etc)

	/* TIME-RELATED */
	public static inline var BLIZZARD:Int = 50;		// the minimum amount of time allowed between snowflake spawns
	private static inline var SHOWER:Int = 250;		// the initial spawn rate for snowflakes
	private static inline var FLURRY:Int = 1000;	// the slowest spawn rate
	public static var spawnRate:Int = SHOWER;		// the amount of time between snowflake spawns
	private static inline var SPAWNRATE_DECREMENTER:Int = 5;	// rate at which the time between snowflake spawns is decremented by
	private static var spawnTimer:Float = 0;		// the timer for determining when to spawn snowflakes

	public static var flamTimer:Float = 0;			// the timer used to create separation between notes
	public static var flamNotes:Array<SoundDef> = [];			// the notes to be flammed at any given time
	public static var flamRate:Int = 25;			// the time between flammed notes
	private static var flamCounter:Int = 0;			// used to count through the notes in a chord/etc to be flammed
	public static var sounds:Array<SoundDef> = [];

	public static var onAutoPilot:Bool = false;		// whether or not game is on autopilot or not
	public static var autoPilotMovement:String = "Right";
	public static var inImprovMode:Bool = false;	// whether or not game is in improv mode
	public static var inSpellMode:Bool = false;		// whether or not notes and chords are displayed onLick.

	/** Initialize game, create and add everything. */
	override public function create():Void
	{
		Reg.score = SCORE_INIT;
		FlxG.sound.volume = 1;
		#if flash
		FlxG.sound.playMusic(AssetPaths.ambience__mp3, 0.025);
		#else
		FlxG.sound.playMusic(AssetPaths.ambience__ogg, 0.025);
		#end
		FlxG.sound.music.fadeIn(2, 0, 0.025);

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

		// Add Feedback Texts
		txtOptions   = new Text(0xFFDEE2E2); add(txtOptions);
		txtNumbers   = new Text(0xFFF1F4F4); add(txtNumbers);
		txtScales    = new Text(0xFFDEE2E2); add(txtScales);
		txtNoteNames = new Text(0xFFF1F4F4); add(txtNoteNames);

		// Draw Player
		player = new Player();
		add(player);

		// Create Snow
		snow = new FlxTypedGroup<Snowflake>();
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

		FlxG.watch.add(Reg, "wasLeftStickX");
		FlxG.watch.add(Reg, "wasLeftStickY");
		FlxG.watch.add(Reg, "wasRightStickX");
		FlxG.watch.add(Reg, "wasRightStickY");
	}

	static public function loadSound(Sound:String, Volume:Float, Pan:Float):SoundDef
	{
		if (StringTools.endsWith(Sound, "null"))
			return null;

		var note:Tone = new Tone();
		note.loadEmbedded(Assets.getSound(getFilename(Sound)), false);
		note.pan = Pan;

		var toFadeIn:Bool = false;

		if (Playback.attackTimeID > 0) {

			toFadeIn = true;
			note.volume = 0;
		}
		else
			note.volume = Volume;

		var s:SoundDef = {name: Sound, note: note, toFadeIn: toFadeIn, vol: Volume};
		sounds.push(s);
		return s;
	}

	static public function playSound(Sound:String, Volume:Float, Pan:Float):SoundDef
	{
		var s:SoundDef = loadSound(Sound, Volume, Pan);

		if (s.toFadeIn)
			s.note.fadeI(Playback.attackTime, Volume);
		else
			s.note.play();

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

				if (flamNote.toFadeIn)
					flamNote.note.fadeI(Playback.attackTime, flamNote.vol);
				else
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
		if (spawnTimer <= 0) {

			if (spawnRate <= BLIZZARD)
				spawnRate = BLIZZARD;

			spawnTimer = spawnRate / 1000;
			SnowflakeManager.manage();

			// Improv Mode. Some features are shared with Auto Pilot Mode
			if (inImprovMode || onAutoPilot)
			{
				// Change Game Mode
				if (Playback.mode == "Repeat") {

					if (FlxG.random.bool(0.25))
						Playback.cycle(FlxG.random.bool(50) ? "Left" : "Right");
					else if (FlxG.random.bool(0.1))
						Playback.polarity();
				}
				else {

					if (Reg.score > 0 && FlxG.random.bool(0.5))
						Playback.repeat();
				}

				// Toggle Pentatonic Scale Usage
				if (FlxG.random.bool(0.4)) Scale.togglePentatonics();
				// Toggle Note Lengths
				if (FlxG.random.bool(0.4)) Playback.changeNoteLengths();
				// Toggle Attack Times
				if (FlxG.random.bool(0.4)) Playback.changeAttackTimes();

				// Toggle Pedal Point
				if (Pedal.mode == false && FlxG.random.bool(0.2))
					Pedal.toggle();
				else if (Pedal.mode  && FlxG.random.bool(0.5))
					Pedal.toggle();

				// Toggle Mode and Key Changes
				if (FlxG.random.bool(0.25))	Mode.cycle(FlxG.random.bool(0.5) ? "Left" : "Right");
				if (FlxG.random.bool(0.05))	Key.cycle();

				// Toggle Weather
				// if (FlxG.random.bool(0.05))	changeSnow();
			}

			// Auto Pilot Mode
			if (onAutoPilot) {

				// Change Tongue Position
				if (player.tongueUp) {

					if (FlxG.random.bool(2))
						player.tongueUp = !player.tongueUp;
				}
				else {

					if (FlxG.random.bool(10))
						player.tongueUp = !player.tongueUp;
				}

				// Change Player Movement
				if (FlxG.random.bool(2))
					autoPilotMovement = FlxG.random.getObject(["Left", "Right", "Still"]);
			}
		}

		super.update(elapsed);

		// Loop Sky Background
		if (sky.x < -716) sky.x = 0;

		if (HUD.promptText.exists)
		{
			#if ( !flash && !FLX_NO_KEYBOARD )
			if (FlxG.keys.justPressed.Y)		Sys.exit(0);
			else if (FlxG.keys.justPressed.N)	HUD.hideExit();
			#end
		}
		else
		{
			// Collision Check
			if (player.tongueUp) FlxG.overlap(snow, player, onLick);

			// Key input checks for advanced features!.
			if (Reg.inputJustPressed(Reg.ACT_SNOW_FREQ))			changeSnow();

			if (Reg.inputJustPressed(Reg.ACT_CHANGEKEY))			Key.cycle();
			if (Reg.inputJustPressed(Reg.ACT_MUSICMODE_L))			Mode.cycle("Left");
			if (Reg.inputJustPressed(Reg.ACT_MUSICMODE_R))			Mode.cycle("Right");
			if (Reg.inputJustPressed(Reg.ACT_PENTATONICS))	 		Scale.togglePentatonics();
			if (Reg.inputJustPressed(Reg.ACT_PEDALPOINT)) 			Pedal.toggle();

			if (Reg.inputJustPressed(Reg.ACT_GAMEMODE_L))			Playback.cycle("Left");
			if (Reg.inputJustPressed(Reg.ACT_GAMEMODE_R))			Playback.cycle("Right");
			if (Reg.inputJustPressed(Reg.ACT_REVERSE))				Playback.polarity();
			if (Reg.inputJustPressed(Reg.ACT_RESET))				Playback.resetRestart();

			if (Reg.inputJustPressed(Reg.ACT_NOTE_LENGTH))			Playback.changeNoteLengths();
			if (Reg.inputJustPressed(Reg.ACT_ATTACK_TIME))			Playback.changeAttackTimes();
			if (Reg.inputJustPressed(Reg.ACT_NOTE_NAMES))			spellMode();
			if (Reg.inputJustPressed(Reg.ACT_IMPROV))				improvise();
			if (Reg.inputJustPressed(Reg.ACT_AUTOPILOT))			autoPilot();

			if (Reg.inputJustPressed(Reg.ACT_HUD))					HUD.toggle();
			if (Reg.inputJustPressed(Reg.ACT_SAVE))					HUD.midi();

			#if (!flash && !FLX_NO_KEYBOARD)
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)	MIDI.generate();
			if (FlxG.keys.justPressed.F)								FlxG.fullscreen = !FlxG.fullscreen;
			if (FlxG.keys.justPressed.ESCAPE)							HUD.promptExit();
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

		#if !FLX_NO_GAMEPAD
		if(FlxG.gamepads.lastActive != null)
			Reg.stickCheck();
		#end
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

		// Text Stuff
		var _text:String = "";

		// Singular Notes Show Numbers in Repeat Mode, otherwise Note Names if in Spell Mode.
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

				if (_text != "")
					txtNumbers.show(_text, 5);
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

				if (_text != "")
					txtNoteNames.show(_text);
			}

		}
		else {

			// Chords
			if (PlayState.inSpellMode)
				txtScales.show(Std.string(HUD.modeName));
		}

		spawnRate -= SPAWNRATE_DECREMENTER;
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ADVANCED FEATURES /////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	private static function spellMode():Void {

		inSpellMode = !inSpellMode;
		var status:String = inSpellMode ? "Show" : "Hide";

		txtOptions.show(status + " Notes");
	}

	private static function changeSnow():Void
	{
		var txt:String = "";

		spawnRate = spawnRate == SHOWER ? BLIZZARD : spawnRate == BLIZZARD ? FLURRY : SHOWER;
		txt = spawnRate == SHOWER ? "Shower" : spawnRate == BLIZZARD ? "Blizzard" : "Flurry";

		txtOptions.show(txt);
	}

	private static function autoPilot():Void
	{
		onAutoPilot = !onAutoPilot;
		player.tongueUp = onAutoPilot;
		txtOptions.show("Auto Pilot " + (onAutoPilot ? "On" : "Off"));
	}

	private function improvise():Void
	{
		inImprovMode = !inImprovMode;
		txtOptions.show("Improv Mode " + (inImprovMode ? "On" : "Off"));
	}
}
