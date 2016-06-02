package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;

class MenuState extends FlxState
{
	
	private static var yesText:FlxText;
	private static var leaving:Bool = false;
	
	override public function create():Void
	{
		bgColor = 0xFF75899C;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.load(AssetPaths.cursor__png, 3);
		#end
		
		yesText = new FlxText(0, 0, 0, "Click to Play");
		yesText.setFormat(AssetPaths.frucade__ttf);
		yesText.screenCenter();
		add(yesText);
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = true;
		#end
		
		super.create();
	}

	private function newState():Void
	{
		if (leaving)
			return;
		leaving = true;
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
		
		FlxG.switchState(new PlayState());
	}
	
	override public function destroy():Void
	{
		yesText = FlxDestroyUtil.destroy(yesText);
		super.destroy();
	}

	
	override public function update(elapsed:Float):Void
	{
		
		if (Reg.inputJustReleased(Reg.ACT_ANY))
			newState();
		
		
		#if !FLX_NO_MOUSE
		if (FlxG.mouse.justReleased)
			newState();
		#end
		
		super.update(elapsed);
	}
}
