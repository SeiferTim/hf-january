package music;

class Note
{

	/** The loudest possible volume for a snowflake tone. */
	public static inline var MAX_VOLUME:Float = 0.5;
	
	/** An array of all of the Note sounds. */
	public static var DATABASE:Array<String> = ["C1", "Cs1", "D1", "Ds1", "E1", "F1", "Fs1", "G1", "Gs1", "A1", "As1", "B1", "C2", "Cs2", "D2", "Ds2", "E2", "F2", "Fs2", "G2", "Gs2", "A2", "As2", "B2", "C3", "Cs3", "D3", "Ds3", "E3", "F3", "Fs3", "G3", "Gs3", "A3", "As3", "B3", "C4", "Cs4", "D4", "Ds4", "E4", "F4", "Fs4", "G4", "Gs4", "A4", "As4", "B4"];
	
	/** The very first note that's triggered. */
	public static var initial:String;
	/** The last Play Note played. */
	public static var lastRecorded:String;		
	/** The second to last Play Note played. */
	public static var secondToLastRecorded:String;	
	/** The last Note played, regardless of whether in Play/Replay Mode **/
	public static var lastAbsolute:String;
	/** The last Octave Note played. */
	public static var lastOctave:String;
	/** The last Harmony Note played. */
	public static var lastHarmony:String;
	/** The last Pedal Note played. */
	public static var lastPedal:String;
}