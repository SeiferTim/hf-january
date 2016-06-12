package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxSoundAsset;
import music.Intervals;
import music.Key;
import music.MIDI;
import music.Mode;
import music.Note;
import music.Tone;
import music.Pedal;
import music.Playback;
import music.Scale;
import openfl.utils.Object;
import snowflakes.Chord;
import snowflakes.Harmony;
import snowflakes.Octave;
import snowflakes.Small;
import snowflakes.Transpose;
import snowflakes.Vamp;

class Snowflake extends FlxSprite {

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MUSIC-RELATED DEFINITIONS ///////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/** Volume for the Note. */
	var volume:Float = 0;
	/** Pan Value for the Note, measured in -1 to 1. */
	var pan:Float = 0; //FlxG.random.float(-1, 1);
	/** Whether the Snowflake in question allows for a pedal tone. */
	var pedalAllowed:Bool = false;
	/** Whether the Snowflake in question plays a note. */
	public var playsNote:Bool = false;
	/** The note this Snowflake is slated to play. */
	public var noteName:String = "n/a";

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// NON-MUSIC DEFINITIONS ///////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/** The type of snowflake in question. */
	public var type:String = "";
	/** Type of the last licked snowflake. */
	private static var lastLickedType:String = "";
	/** Horizontal modifier for snowflake movement. */
	var windX:Float = 0;
	/** Vertical modifier for snowflake movement. */
	var windY:Float = 0;

	////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public function new() {

		super();
		exists = false;
	}

	/** Spawns snowflakes. */
	public function spawn(flakeType:String, spawnX:Float = 0):Void {

		// POSITION
		if (spawnX != 0)
			x = spawnX;
		else
			x = FlxG.random.int(0, FlxG.width);

		y = height * -1;

		type = flakeType;
		exists = true;
	}

	override public function update(elapsed:Float):Void
	{
		//////////////
		// MOVEMENT //
		//////////////

		windX = 5 + (Reg.score * 0.025);

		if (windX >= 10)
			windX = 10;

		velocity.x = (Math.cos(y / windX) * windX);

		if (Reg.score == 0)
			velocity.y = 15;
		else
			velocity.y = 5 + (Math.cos(y / 25) * 5) + windY;

		super.update(elapsed);

		///////////////
		// COLLISION //
		///////////////

		if (( y > FlxG.height - 14 && (x + width <= PlayState.player.x || x >= PlayState.player.x + PlayState.player.width)))
			super.kill();
		else if (y >= FlxG.height - 1 || x < 0 - width || x > FlxG.width)
			super.kill();
	}

	/** Called when a Snowflake has been licked. */
	public function onLick():Void
	{
		super.kill();

		Reg.score++;

		// Count How Many of Each Flake Type is Licked, For Custom MIDI File Name
		if (type != "Small")
			PlayState.scores.set(type, PlayState.scores.get(type) + 1);

		lastLickedType = type;

		pan = getLocationalPan();
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MUSIC FUNCTIONS //////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	/** Determines which kind of note to play. */
	private function playNote():Void
	{

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
		var sound:Tone;
		if (Playback.sequence.length == 0)
		{
			if (Note.lastAbsolute != null)
			{

				noteName = Note.lastAbsolute;
				PlayState.playSound(noteName, volume, pan);
				Playback.index = 1;
			}
			else
			{
				return;
			}
		}
		else
		{
			// Convert Interval String in Sequence to Note, then play it.
			var id:String = Playback.sequence[Playback.index];
			noteName = Intervals.loadout.get(id);

			if (SnowflakeManager.timbre == "Primary")
				sound = PlayState.playSound(noteName, volume, pan).note;
			else
				sound = PlayState.playSound("_" + noteName, volume / SnowflakeManager._volumeMod, pan).note;

			setFadeAmt(sound);

			Note.lastAbsolute = Intervals.loadout.get(id);

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
		for (interval in Intervals.loadout.keys())
		{
			if (Note.lastRecorded == Intervals.loadout.get(interval))
			{
				Playback.sequence.push(interval);

				break;
			}
		}

		// Limit Playback Sequence Size
		if (Playback.sequence.length > Playback.MAX_SEQUENCE)
			Playback.sequence.shift();
	}

	/** Play a note! Takes in an array of classes, and will pick one randomly. */
	private function _play(options: Array<String>):Void
	{
		noteName = noteAdjustments(options);
		var sound:Tone;

		if (SnowflakeManager.timbre == "Primary")
			sound = PlayState.playSound(noteName, volume, pan).note;
		else
		{
			var modifiedNote:FlxSoundAsset = "_" + noteName;
			sound = PlayState.playSound( modifiedNote, volume/SnowflakeManager._volumeMod, pan).note;
		}

		setFadeAmt(sound);

		// LOGS
		MIDI.log(noteName, volume);
		Note.secondToLastRecorded = Note.lastRecorded;
		Note.lastRecorded = noteName;
		Note.lastAbsolute = Note.lastRecorded;
		HUD.logNote(volume, pan);
	}

	private function playChord():Void
	{

		// DETERMINE CHORD TONES
		var chordTones:Array<String> =  FlxG.random.getObject(Mode.current.chords);

		// PUSH NOTES TO FLAM TIMER
		pan = getLocationalPan();

		var s1:PlayState.SoundDef;
		var s2:PlayState.SoundDef;
		var s3:PlayState.SoundDef;

		if (SnowflakeManager.timbre == "Primary")
		{
			s1 = PlayState.loadSound(Intervals.loadout.get(chordTones[0]), Chord.VOLUME, pan);
			s2 = PlayState.loadSound(Intervals.loadout.get(chordTones[1]), Chord.VOLUME, pan);
			s3 = PlayState.loadSound(Intervals.loadout.get(chordTones[2]), Chord.VOLUME, pan);

		}
		else
		{
			var _s1: String = "_" + Intervals.loadout.get(chordTones[0]);
			var _s2: String = "_" + Intervals.loadout.get(chordTones[1]);
			var _s3: String = "_" + Intervals.loadout.get(chordTones[2]);
			var _vol: Float = Chord.VOLUME/SnowflakeManager._volumeMod;

			s1 = PlayState.loadSound(_s1, _vol, pan);
			s2 = PlayState.loadSound(_s2, _vol, pan);
			s3 = PlayState.loadSound(_s3, _vol, pan);

		}

		if (type == "Vamp")
		{
			s1.note.play();
			MIDI.log(Intervals.loadout.get(chordTones[0]), Chord.VOLUME);
		}
		else
			PlayState.flamNotes.push(s1);

		PlayState.flamNotes.push(s2);
		PlayState.flamNotes.push(s3);

		// Create array of classes for HUD logging.
		var events: Array<String> = [ Intervals.loadout.get(chordTones[0]), Intervals.loadout.get(chordTones[1]), Intervals.loadout.get(chordTones[2]) ];

		// If the chord is a seventh chord, push the 4th chord tone.

		if (chordTones.length > 3 && Intervals.loadout.get(chordTones[3]) != null)
		{
			var s4:PlayState.SoundDef;

			if (SnowflakeManager.timbre == "Primary")
				s4 = PlayState.loadSound(Intervals.loadout.get(chordTones[3]), Chord.VOLUME, pan);
			else
			{
				var _s4: String = "_" + Intervals.loadout.get(chordTones[3]);
				s4 = PlayState.loadSound(_s4, Chord.VOLUME / SnowflakeManager._volumeMod, pan);
			}
			PlayState.flamNotes.push(s4);

			events[3] = Intervals.loadout.get(chordTones[3]);
		}

		PlayState.flamTimer = PlayState.flamRate / 1000;

		HUD.logMode();
		HUD.logEvent(events);
	}

	private function playPedalTone():Void
	{
		var pedalTone:String = Note.lastAbsolute;
		var sound:Tone;

		while (pedalTone == Note.lastAbsolute
			|| pedalTone == Note.lastPedal
			||(pedalTone == Note.lastOctave && type == "Octave")
			||(pedalTone == Note.lastHarmony && type == "Harmony"))
		{
			pedalTone = FlxG.random.getObject([Intervals.loadout.get("one1"), Intervals.loadout.get("fiv1"), Intervals.loadout.get("one2"), Intervals.loadout.get("fiv2")]);
		}

		if (SnowflakeManager.timbre == "Primary")
			sound = PlayState.playSound(pedalTone, volume/2, 0).note;
		else
		{
			var modifiedNote: String = "_" + pedalTone;
			sound = PlayState.playSound(modifiedNote, volume/(2 + SnowflakeManager._volumeMod), 0).note;
		}

		setFadeAmt(sound);

		Note.lastPedal = pedalTone;
		MIDI.log(pedalTone, volume/2);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// MODE FUNCTIONS //////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	/** Uses the option sets of the current mode to choose which note to generate. */
	private function generateNote():Void
	{
		var played:Bool = false;
		var optionSets: Array<Array<String>>;

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

		for (j in 0...Intervals.DATABASE.length)
		{
			if (Note.lastRecorded == Intervals.loadout.get(Intervals.DATABASE[j]))
			{
				_play(optionSets[j]);
				played = true;

				break;
			}
		}

		if (!played)
			_play(optionSets[22]);	// [22] is the else statement.
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// MUSIC HELPERS ///////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////

	private function getLocationalPan():Float {

		// Convert x position to pan position.
		return 2 * ((this.x / FlxG.width)) - 1;
	}

	private function setFadeAmt(sound: Tone):Void
	{
		var fadeAmt:Float;

		switch (Playback.noteLengthID) {

			case 0	: fadeAmt = FlxG.random.float(1, 8);
			case 1	: fadeAmt = FlxG.random.float(1, 2);
			case 2	: fadeAmt = FlxG.random.float(2, 4);
			default	: fadeAmt = 0;
		}

		if (fadeAmt != 0)
			sound.fadeO(fadeAmt);
	}

	private function noteAdjustments(options: Array<String>):String
	{
		var note: String = "";
		var random:Int = 0;

		// NOTE PREVENTIONS
		random = FlxG.random.int(0, options.length - 1);
		note = Intervals.loadout.get(options[random]);

		// Halve Probability of Trills and Repeats
		if (note == Note.secondToLastRecorded || note == Note.lastAbsolute)
		{
			random = FlxG.random.int(0, options.length - 1);
			note = Intervals.loadout.get(options[random]);
		}

		var g:Int = 0;
		while (g < 100 && (note == null
			|| (note == Note.lastHarmony && lastLickedType == "Harmony")
			|| (note == Note.lastOctave && lastLickedType == "Octave")
			|| (type == "Octave" && (note == Intervals.loadout.get("for1") || note == Intervals.loadout.get("for2") || note == Intervals.loadout.get("for3"))) ))
		{
			random = FlxG.random.int(0, options.length - 1);
			note = Intervals.loadout.get(options[random]);
			g++;
		}

		// Prevent certain tensions from triggering on record mode key changes
		if (Key.justChanged
			&& Mode.current != Mode.MIXOLYDIAN
			&& (note == Intervals.loadout.get("two1") ||
				note == Intervals.loadout.get("for1") ||
				note == Intervals.loadout.get("six1") ||
				note == Intervals.loadout.get("for2") ||
				note == Intervals.loadout.get("six2") ||
				note == Intervals.loadout.get("for3") ||
				note == Intervals.loadout.get("six3")) )
		{
			for (desc in Intervals.loadout.keys())
			{
				if (note == Intervals.loadout.get(desc))
				{
					for (j in 0...Intervals.DATABASE.length)
					{
						if (Intervals.loadout.get(desc) == Intervals.DATABASE[j])
						{
							// change new note to be +/- 1 interval if the key just changed.
							note = Intervals.loadout.get(Intervals.DATABASE[j + FlxG.random.sign()]);
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