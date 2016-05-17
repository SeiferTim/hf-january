package;

import flixel.ui.FlxButton;

class Button extends FlxButton
{

	public function new() 
	{
		super(0, 0, "");
		loadGraphic(AssetPaths.midi_button__png, true, 97, 16);
		animation.add("default", [0, 1], 3);
		scrollFactor.x = 0;
		exists = false;
		
	}
	
	override function updateButton():Void 
	{
		super.updateButton();
		animation.play("default");
	}
	
}