package music;
import openfl.utils.Object;

class Intervals
{

	/** An array of the interval names, used as a reference for populating the intervals object. */ 
	public static var DATABASE:Array<String> = ["one1", "two1", "thr1", "for1", "fiv1", "six1", "sev1", "one2", "two2", "thr2", "for2", "fiv2", "six2", "sev2", "one3", "two3", "thr3", "for3", "fiv3", "six3", "sev3", "one4"];
	/** Whether the Intervals.loadout object is up to date or not. */
	public static var updated:Bool = false;
	/** The intervals object, populated with the notes of the current key, ordered by the current mode. */
	public static var loadout:Map<String, String>;
	
	public static function populate():Void
	{
		// If the Intervals.loadout object is not already populated with the current key,
		if (updated == false)
		{						
			var modeOffset:Int;
			if (Key.current == "C Minor")
				modeOffset = Mode.DATABASE[Mode.index].minorPos;
			else
				modeOffset = Mode.DATABASE[Mode.index].majorPos;
			
				
			loadout = new Map<String, String>();
			for (i in 0...DATABASE.length)
				loadout.set(DATABASE[i], Key.DATABASE[Key.index][i + modeOffset]);
			
			updated = true;
		}	
	}
}