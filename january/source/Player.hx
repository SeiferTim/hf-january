package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Player extends FlxSprite
{

	//[Embed(source="../assets/art/player1.png")] private var sprite: Class;

	/** Initial Player X Position. */
	public static inline var X_INIT:Int = 20;
	/** Size of the player's boundary on the left side of the screen, in pixels. */
	private var boundsLeft:Int = 0;
	/** Whether the player has stopped moving. */
	private var stopped:Bool = false;
	/** Whether the player's tongue is up. */
	public var tongueUp:Bool = false;

	private var wasMoving:Bool = false;
	
	public function new()
	{
		x = X_INIT;
		y = 79;

		super(x, y);
		loadGraphic(AssetPaths.player1__png, true, 16, 33);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		width    = 10;
		height   = 3;
		offset.x = 4;
		offset.y = 7;

		// Set player's x position bounds
		boundsLeft = 2;

		// Add animations.
		animation.add("idle", [78,79,80,81,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0], 6, false);
		animation.add("tongueUpStopped", [73,74,75,76,5,5,5,5,5,6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,5], 6, false);
		animation.add("tongueUp", [2,3,4,5], 18, false);
		animation.add("tongueDown", [4,3,2,0], 18, false);
		animation.add("walk", [33,35,37,7,9,11,13,15,17,19,21,23,25,27,29,31], 12);
		animation.add("walkTongue", [66,68,70,40,42,44,46,48,50,52,54,56,58,60,62,64], 12);
	}

	override public function update(elapsed:Float):Void
	{
		//////////////
		// MOVEMENT //
		//////////////

		acceleration.x = 0;
		

		if ( (animation.frameIndex >= 11 && animation.frameIndex <= 14) || (animation.frameIndex >= 27 && animation.frameIndex <= 31) || (animation.frameIndex >= 44 && animation.frameIndex <= 47) || (animation.frameIndex >= 60 && animation.frameIndex <= 64) )
			maxVelocity.x = 20;
		else
			maxVelocity.x = 40;

    if (Reg.inputPressed(Reg.ACT_SPEEDUP))
			maxVelocity.x = 60;
		
			
		var left:Bool = false;
		var right:Bool = false;
		
		left = left || Reg.inputPressed(Reg.ACT_PLAYER_MOVE_L) || (PlayState.onAutoPilot && PlayState.autoPilotMovement == "Left");
		right = right || Reg.inputPressed(Reg.ACT_PLAYER_MOVE_R) || (PlayState.onAutoPilot && PlayState.autoPilotMovement == "Right");
		if ((left && right) || (PlayState.onAutoPilot && PlayState.autoPilotMovement == "Still"))
			left = right = false;
			
		if (left)
		{
			facing = FlxObject.LEFT;
			SnowflakeManager.timbre = "Secondary";
			velocity.x = -maxVelocity.x;
			wasMoving = true;
		}
		else if (right)
		{
			facing = FlxObject.RIGHT;
			SnowflakeManager.timbre = "Primary";
			velocity.x = maxVelocity.x;
			wasMoving = true;
		}
		if (wasMoving && !left && !right)
		{
			drag.x = 100;
			stopped = true;
		}

		///////////////
		// ANIMATION //
		///////////////

		var up:Bool = Reg.inputPressed(Reg.ACT_TONGUE_OUT); 
		var down:Bool = Reg.inputPressed(Reg.ACT_TONGUE_IN);

		if (velocity.x != 0)
		{
			if (tongueUp == false)
				animation.play("walk");
			else
				animation.play("walkTongue");

			if (up)
				tongueUp = true;
			else if (down)
				tongueUp = false;
		}
		else	// if player velocity is 0
		{
			if (tongueUp == false && up)	// and still looking up
			{
				animation.play("tongueUp");
				tongueUp = true;
			}
			else if (tongueUp == true && down)
			{
				animation.play("tongueDown");
				tongueUp = false;
			}

			if (stopped == true)
			{
				if (tongueUp == false)
					animation.play("idle");
				else
					animation.play("tongueUpStopped");
			}

			stopped = false;
		}

		super.update(elapsed);

		////////////////
		// COLLISIONS //
		////////////////

		if (x < (-1*width))
			x = FlxG.width;
		else if (x > (FlxG.width + width))
			x = -1*(width);
	}

}