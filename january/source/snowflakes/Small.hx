package snowflakes;
import flixel.FlxG;
import music.Key;
import music.Mode;
import music.Note;
import music.Pedal;
import music.Playback;
import music.Scale;

class Small extends Snowflake
{

	public function new()
	{			
		super();
		
		makeGraphic(1, 1);
		
		windY = 10;
		volume = FlxG.random.float(Note.MAX_VOLUME * 0.33, Note.MAX_VOLUME * 0.83);
		
		pedalAllowed = true;
	}
	
	public override function onLick():Void
	{							
		super.onLick();
		
		if (PlayState.onAutoPilot)
		{
			if (FlxG.random.bool(5))
			{
				if (Playback.mode == "Repeat")
				{
					if (FlxG.random.bool(50))
						Playback.write();
					else
						Playback.detour();
				}
				else if (Reg.score > 0)
					Playback.repeat();
			}
		}
		
		if (PlayState.inImprovMode || PlayState.onAutoPilot)
		{
			if (FlxG.random.bool(4)) Scale.toPentatonic();
			if (FlxG.random.bool(4)) Playback.staccato();
			
			if (Pedal.mode == false && FlxG.random.bool(2))
				Pedal.toggle();
			else if (Pedal.mode  && FlxG.random.bool(5))
				Pedal.toggle();
		}
		
		if (PlayState.inImprovMode)
		{
			if (FlxG.random.bool(1))		Mode.change();
			if (FlxG.random.bool(0.25)) {	Mode.change(); Key.change(); }
		}
		
		playNote();
	}
	
}