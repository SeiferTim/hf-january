package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import openfl.utils.Object;

class Snowflake extends FlxSprite
{

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MUSIC-RELATED DEFINITIONS ///////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////		

	/** Volume for the Note. */
	var volume:Float;	
	/** Pan Value for the Note, measured in -1 to 1. */
	var pan:Float = FlxG.random.float(-1, 1);
	/** Whether the Snowflake in question allows for a pedal tone. */
	var pedalAllowed:Bool;
	/** Used to store Intervals.loadout */
	static var i:Object;
	/** Whether to use primary or secondary timbre set. */
	public static var timbre:String;
	/** Volume Modifier for Secondary Timbre, used to divide original volume. */
	public static var _volumeMod:Float = 1.5;
	
	// List of Secondary Timbre Classes
	//_C1; _Cs1; _D1; _Ds1; _E1; _F1; _Fs1; _G1; _Gs1; _A1; _As1; _B1; _C2; _Cs2; _D2; _Ds2; _E2; _F2; _Fs2; _G2; _Gs2; _A2; _As2; _B2; _C3; _Cs3; _D3; _Ds3; _E3; _F3; _Fs3; _G3; _Gs3; _A3; _As3; _B3; _C4; _Cs4; _D4; _Ds4; _E4; _F4; _Fs4; _G4; _Gs4; _A4; _As4; _B4;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// NON-MUSIC DEFINITIONS ///////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/** The type of snowflake in question. */
	public var type:String = "";
	/** Type of the last licked snowflake. */
	private static var lastLickedType:String;
	/** Horizontal modifier for snowflake movement. */
	var windX:Int = 0;
	/** Vertical modifier for snowflake movement. */
	var windY:Int = 0;
	
	// Snowflake spawning probabilities
	private static var flakes:Array<String> = ["Small", "Octave", "Harmony", "Chord", "Vamp", "Transpose"];
	public static var weights:Array<Float> = [ 88.5  ,  3.5	 ,  3.5		,  2	 ,	2	 ,  0.5		  ];
	
	// List of classes for getDefinitionByName() to use
	//Small; Octave; Harmony; Chord; Vamp; Transpose;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public function new()
	{	
		super();
		exists = false;
	}
	
	/** Determines which snowflakes to spawn.  */
	public static function manage():Void
	{													
		// All Flakes are Spawned based on weighted probability, except for the first one.
		var flakeID:String = flakes[FlxG.random.weightedPick(weights)];
		
		// use string above to instantiate proper Snowflake Subclass.
		var subClass:Class<Snowflake> = getDefinitionByName( "snowflakes." + flakeID );			
		var flake:Snowflake = PlayState.snow.recycle(subClass);
		flake.spawn(flakeID);		
	}
	
	/** Spawns snowflakes. */
	public function spawn(flakeType:String, spawnX:Float = 0):Void
	{																		
		// POSITION
		if (spawnX != 0)
			x = spawnX;
		else
			x = FlxG.random.int(0, FlxG.width);		
			
		y = height * -1;
				
		type = flakeType;
		exists = true;
	}
	
	override public function update():Void
	{			
		//////////////
		// MOVEMENT //
		//////////////
		
		windX = 5 + (FlxG.score * 0.025);
	
		if (windX >= 10)
			windX = 10;
		
		velocity.x = (Math.cos(y / windX) * windX);
			
		if (FlxG.score == 0)
			velocity.y = 15;
		else
			velocity.y = 5 + (Math.cos(y / 25) * 5) + windY;
		
		super.update();
		
		///////////////
		// COLLISION //
		///////////////
		
		if (( y > FlxG.height - 14 && (x + width <= PlayState.player.x || x >= PlayState.player.x + PlayState.player.width)))
			kill();
		else if (y >= FlxG.height - 1 || x < 0 - width || x > FlxG.width)
			kill();
	}
	
	/** Called when a Snowflake has been licked. */
	public function onLick():Void
	{							
		super.kill();
		
		FlxG.score++;
		
		// Count How Many of Each Flake Type is Licked, For Custom MIDI File Name
		if (type != "Small")
			PlayState.scores[type]++;
		
		lastLickedType = type;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MUSIC FUNCTIONS //////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/** Determines which kind of note to play. */
	private function playNote():Void
	{									
		i = Intervals.loadout;
		
		if (Playback.mode == "Repeat")									
			playSequence();
		else
			generateNote();
		
		if (Playback.mode == "Write")
			manageSequence();
		
		if (Pedal.mode == true)
			if (pedalAllowed) playPedalTone();
	}
	
	/** Plays a repeat note, pulled from a sequence of stored notes. */
	private function playSequence():Void
	{
		//FlxG.log("playback()");
		
		if (Playback.sequence.length == 0)
		{
			FlxG.play(Note.lastAbsolute, volume, pan);
			Playback.index = 1;
		}
		else
		{				
			// Convert Interval String in Sequence to Note, then play it.
			var id:String = Playback.sequence[Playback.index];
			var sound:FlxSound;
			
			if (timbre == "Primary")
				sound = FlxG.play(i[id], volume, pan);
			else
			{
				var modifiedNote: Class = getDefinitionByName("_" + getQualifiedClassName(i[id] ) ) ;
				sound = FlxG.play(modifiedNote, volume/_volumeMod, pan);
			}
			
			inStaccato(sound);
			
			Note.lastAbsolute = i[id];			
			
			// Index Counting 
			if (Playback.reverse == false)
			{
				Playback.index++;
			
				if (Playback.index > Playback.sequence.length - 1)
					Playback.index = 0;
			}
			else
			{
				Playback.index--;
				
				if (Playback.index < 0)
					Playback.index = Playback.sequence.length - 1;
			}
		}
		
		MIDI.log(Note.lastAbsolute, volume);
		HUD.logNote(volume, pan);
	}
	
	private function manageSequence():Void
	{			
		// Push reference to interval to sequence array (strings)
		for (interval in i)
		{
			if (Note.lastRecorded == i[interval])
			{
				Playback.sequence.push(interval);
				
				break;
			}
		}
		
		// Limit Playback Sequence Size
		if (Playback.sequence.length > 8)
			Playback.sequence.shift();
	}
	
	/** Play a note! Takes in an array of classes, and will pick one randomly. */	
	private function _play(options: Array<String>):Void
	{				
		var randomNote: Class = noteAdjustments(options);
		var sound: FlxSound;
		
		if (timbre == "Primary")
			sound = FlxG.play(randomNote, volume, pan);
		else
		{
			var modifiedNote: Class = getDefinitionByName("_" + getQualifiedClassName(randomNote) ) ;
			sound = FlxG.play(modifiedNote, volume/_volumeMod, pan);
		}
		
		inStaccato(sound);
		
		// LOGS
		MIDI.log(randomNote, volume);
		Note.secondToLastRecorded = Note.lastRecorded;
		Note.lastRecorded = randomNote;
		Note.lastAbsolute = Note.lastRecorded;
		HUD.logNote(volume, pan);
	}
			
	private function playChord():Void
	{					
		i = Intervals.loadout;
		
		// DETERMINE CHORD TONES
		var chordTones:Array =  FlxG.random.getObject(FlxG.random.getObject(Mode.current.chords));
	
		// PUSH NOTES TO FLAM TIMER
		calculatePan();				
		
		var s1:FlxSound;
		var s2:FlxSound;
		var s3:FlxSound;
		
		if (timbre == "Primary")
		{
			s1 = FlxG.loadSound(i[chordTones[0]], Chord.VOLUME, 0);
			s2 = FlxG.loadSound(i[chordTones[1]], Chord.VOLUME, -1);
			s3 = FlxG.loadSound(i[chordTones[2]], Chord.VOLUME, 1);
		}
		else
		{
			var _s1: Class = getDefinitionByName("_" + getQualifiedClassName(i[chordTones[0]]));
			var _s2: Class = getDefinitionByName("_" + getQualifiedClassName(i[chordTones[1]]));
			var _s3: Class = getDefinitionByName("_" + getQualifiedClassName(i[chordTones[2]]));
			var _vol: Number = Chord.VOLUME/_volumeMod;
			
			s1 = FlxG.loadSound(_s1, _vol, 0);
			s2 = FlxG.loadSound(_s2, _vol, -1);
			s3 = FlxG.loadSound(_s3, _vol, 1);
		}
		
		if (type == "Vamp")
		{
			s1.play();
			MIDI.log(i[chordTones[0]], Chord.VOLUME);
		}
		else
			Game.flamNotes.push(s1);
		
		Game.flamNotes.push(s2, s3);
		
		// Create array of classes for HUD logging.
		var events: Array = [ i[chordTones[0]], i[chordTones[1]], i[chordTones[2]] ];
		
		// If the chord is a seventh chord, push the 4th chord tone.
		if (i[chordTones[3]] != null)
		{
			var s4:FlxSound;
			
			if (timbre == "Primary")
				s4 = FlxG.loadSound(i[chordTones[3]], Chord.VOLUME, -1*pan);
			else
			{
				var _s4: Class = getDefinitionByName("_" + getQualifiedClassName(i[chordTones[3]]) );
				s4 = FlxG.loadSound(_s4, Chord.VOLUME/_volumeMod, -1*pan);
			}
				
			Game.flamNotes.push(s4);	
			events[3] = i[chordTones[3]];
		}
		
		Game.flamTimer.start();
		
		HUD.logMode();			
		HUD.logEvent(events);
	}
	
	private function playPedalTone():Void
	{	
		var pedalTone:Class = Note.lastAbsolute;
		var sound:FlxSound;
		
		while (pedalTone == Note.lastAbsolute 
			|| pedalTone == Note.lastPedal
			||(pedalTone == Note.lastOctave && type == "Octave")
			||(pedalTone == Note.lastHarmony && type == "Harmony"))
		{
			pedalTone = FlxG.random.getObject(i.one1, i.fiv1, i.one2, i.fiv2);
		}
		
		if (timbre == "Primary")
			sound = FlxG.play(pedalTone, volume/2, 0);
		else
		{
			var modifiedNote: Class = getDefinitionByName("_" + getQualifiedClassName(pedalTone));
			sound = FlxG.play(modifiedNote, volume/(2 + _volumeMod), 0);
		}
		
		inStaccato(sound);
		
		Note.lastPedal = pedalTone;
		MIDI.log(pedalTone, volume/2);
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// MODE FUNCTIONS //////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/** Uses the option sets of the current mode to choose which note to generate. */
	private function generateNote():Void
	{
		var played:Bool;
		var optionSets: Array;
		
		if (Scale.isPentatonic == false)
			optionSets = Mode.current.logic;
		else
		{
			if (Mode.current == Mode.AEOLIAN ||
				Mode.current == Mode.DORIAN)
				optionSets = Scale.MINOR_PENTATONIC.logic;
			else
				optionSets = Scale.MAJOR_PENTATONIC.logic;
		}
			
		for (j in 0...Intervals.DATABASE.length - 1)
		{				
			if (Note.lastRecorded == i[Intervals.DATABASE[j]])
			{					
				_play(optionSets[j]);
				played = true;
				
				break;
			}
		}
		
		if (played == false)
			_play(optionSets[22]);	// [22] is the else statement.
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// MUSIC HELPERS ///////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private function calculatePan():Void
	{
		// Convert x position to pan position.
		pan = 2 * ((this.x / FlxG.width)) - 1;
	}
	
	private function inStaccato(sound: FlxSound):Void
	{
		if (Playback.noteLength != "Full")
		{
			var fadeAmt:Float;
			
			if (Playback.noteLength == "Random")
				fadeAmt = FlxG.random.float(2, 8);
			else
				fadeAmt = 3.75;
			
			sound.fadeOut(fadeAmt);
		}
	}
	
	private function noteAdjustments(options: Array<String>):String
	{
		var note: String;
		var random:Int;
		
		// NOTE PREVENTIONS
		random = FlxG.random.int(0, options.length - 1);
		note = i[options[random]] ;
		
		// Halve Probability of Trills and Repeats
		if (note == Note.secondToLastRecorded || note == Note.lastAbsolute)
		{
			random = FlxG.random.int(0, options.length - 1);
			note = i[options[random]] ;
		}
		
		var g:Int = 0;		
		while (g < 100 && (note == null
			|| (note == Note.lastHarmony && lastLickedType == "Harmony")
			|| (note == Note.lastOctave && lastLickedType == "Octave")
			|| (type == "Octave" && (note == i.for1 || note == i.for2 || note == i.for3)) ))
		{
			random = FlxG.random.int(0, options.length - 1);
			note = i[options[random]] ;
			g++;
		}				
		
		// Prevent certain tensions from triggering on record mode key changes
		if (Key.justChanged
			&& Mode.current != Mode.MIXOLYDIAN
			&& (note == i.two1 ||
				note == i.for1 ||
				note == i.six1 ||
				note == i.for2 ||
				note == i.six2 ||
				note == i.for3 ||
				note == i.six3) )
		{	
			for (desc in i)
			{				
				if (note == i[desc])
				{
					for (j in 0...Intervals.DATABASE.length - 1)
					{
						if (i[desc] == Intervals.DATABASE[j])
						{
							// change new note to be +/- 1 interval if the key just changed.
							note = i[Intervals.DATABASE[j + FlxMath.randomSign()]];	
							break;
						}
					}
				}
			}
			
			Key.justChanged = false;
		}
	
		return note;
		
	}
	
}