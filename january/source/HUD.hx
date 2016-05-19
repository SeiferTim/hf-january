package;
import flixel.FlxG;
import flixel.text.FlxText;
import music.Intervals;
import music.Key;
import music.MIDI;
import music.Mode;
import music.Note;
import music.Scale;
import openfl.display.StageDisplayState;
import openfl.events.MouseEvent;

class HUD
{

	/** The text sprite that holds note name, volume, pan, etc. */
	public static var row1:FlxText;
	/** The text sprite that holds mode type, chord tones, etc. */
	public static var row2:FlxText;
	/** The text sprite that holds chord information, etc. */
	public static var row3:FlxText;
	/** Current mode in fancy form, with key and proper capitalization. */
	public static var modeName:String = "";
	/** Current mode in fancy form, with key and proper capitalization. */
	public static var noteText:String = "";

	/** The "Save as MIDI" button. */
	public static var midiButton:Button;
	/** The font used for HUD objects. */
	public static inline var FONT:String = "frucade";
	/** Regular Expression used to find "s" for sharp. */
	private static var findSharp:EReg = ~/\s*[s]/g;
	
	/** Sets up HUD! does everything but add it to the state. */
	public static function init():Void
	{				
		row1 = new FlxText(4, -1, 256, "");
		row2 = new FlxText(4, 9, 256, "");
		row3 = new FlxText(4, 19, 256, "");
		midiButton = new Button();
		midiButton.x = FlxG.width - midiButton.width - 3;
		midiButton.y = 3;
		row1.scrollFactor.x = row2.scrollFactor.x = row3.scrollFactor.x = 0;
		row1.font = row2.font = row3.font = FONT;
		row1.exists = row2.exists = row3.exists = false;			
	}
		
	/** Turns HUD on or off. */ 
	public static function toggle():Void
	{
		row1.exists = row2.exists = row3.exists = !row3.exists;
	}
	
	public static function midi():Void
	{
		FlxG.stage.displayState = StageDisplayState.NORMAL;
		
		if (FlxG.mouse.visible)
		{
			FlxG.mouse.visible = false;
			FlxG.stage.removeEventListener(MouseEvent.MOUSE_DOWN, MIDI.generate);
		}
		else
		{
			FlxG.mouse.visible = true; 
			FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, MIDI.generate);
		}
		
		midiButton.exists = !midiButton.exists;
	}
	
	/**
	 * Logs Note Data to HUD: ie. C3, 0.26 (volume), -0.3 (pan)
	 * 
	 * @param volume	Volume of note to be logged.
	 * @param pan		Pan position of note to be logged.
	 */		
	public static function logNote(volume:Float, pan:Float):Void
	{					
		row1.text = "";
		
		// Log note name, volume and pan to HUD
		var loggedNote: String = enharmonic(Note.lastAbsolute);	
		var loggedVolume: String = Std.string(Std.int( (volume * 100) * (1 / Note.MAX_VOLUME))) + "%";		
		var loggedPan: String = Std.string(Std.int(pan * 100));
		
		if (loggedPan.indexOf("-") != -1)
		{
			loggedPan = loggedPan.substring(1);
			loggedPan = loggedPan + "% L";
		}
		else if (loggedPan != "0")
			loggedPan = loggedPan + "% R";
		
		noteText = loggedNote + ", in ";
		row1.text = noteText + modeName + ".";
		row2.text = "Vol: " + loggedVolume + ", Pan: " + loggedPan;
	}
	
	/**
	 * Logs Mode Data to HUD.
	 *  
	 * @param currentMode	The current mode.
	 * @param chordTones	If a chord was just played, passes through the chord tones.
	 */		
	public static function logMode():Void
	{
		var keyLetter:String = enharmonic(Intervals.loadout.one1);
		
		if (Scale.isPentatonic)
		{
			if (Mode.current == Mode.AEOLIAN || Mode.current == Mode.DORIAN)
				modeName = "Minor";
			else
				modeName = "Major";
					
			modeName = keyLetter + " " + modeName + " Pentatonic";
		}
		else
			modeName = keyLetter + " " + Mode.current.name;
					
		row1.text = noteText + modeName + ".";
	}
	
	/** Logs Key Data to HUD. */		
	public static function logEvent(chordTones:Array<String> = null):Void
	{
		//FlxG.log("logEvent()");
		
		if (chordTones != null)
		{
			var chordName:String = "";
			for (i in 0...chordTones.length - 1)
			{
				var actualName: String = enharmonic(chordTones[i]);
				chordName += actualName + " ";
			}
			
			row3.text = "Last Chord: " + chordName;
		}
	}
	
	private static function enharmonic(text:String):String
	{
		text = text.substr(0, text.length);
		if (findSharp.match(text))
		{
			if (findSharp.matchedPos().pos == 1)
			{
				text = findSharp.replace(text, "");
				
				for (i in 0...Key.LETTERS.length - 1)
				{
					if (text == Key.LETTERS[i])
					{
						text = Key.LETTERS[i+1];
						break;
					}
				}
				
				text += "b";
			}
		}
		return text;
	}
	
	private static function hide():Void
	{
		row1.exists = row2.exists = row3.exists = false;
	}
	
}