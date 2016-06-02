package;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyList;

import flixel.util.FlxSave;
using flixel.util.FlxArrayUtil;

class Reg
{
	
	public static var score:Int = 0;
	
	public static inline var ACT_PLAYER_MOVE_L:Int 	= 	0;
	public static inline var ACT_PLAYER_MOVE_R:Int 	= 	1;
	public static inline var ACT_TONGUE_OUT:Int 	= 	2;
	public static inline var ACT_TONGUE_IN:Int 		= 	3;
	public static inline var ACT_AUTOPILOT:Int 		= 	4;
	public static inline var ACT_IMPROV:Int	 		= 	5;
	public static inline var ACT_GAMEMODE_L:Int		= 	6;
	public static inline var ACT_GAMEMODE_R:Int		= 	7;
	public static inline var ACT_MUSICMODE_L:Int	= 	8;
	public static inline var ACT_MUSICMODE_R:Int	= 	9;
	public static inline var ACT_HUD:Int			= 	10;
	public static inline var ACT_RESET:Int			= 	11;
	public static inline var ACT_PEDALPOINT:Int		= 	12;
	public static inline var ACT_PENTATONICS:Int	= 	13;
	public static inline var ACT_SPEEDUP:Int		= 	14;
	public static inline var ACT_CHANGEKEY:Int		= 	15;
	public static inline var ACT_SNOW_LESS:Int		= 	16;
	public static inline var ACT_SNOW_MORE:Int		= 	17;
	public static inline var ACT_NOTE_LENGTH:Int	= 	18;
	public static inline var ACT_SAVE:Int			= 	19;
	
	#if !FLX_NO_KEYBOARD
	public static var ActionsKeys:Array<Array<String>>;
		
	public static var KEY_DEFAULT_PLAYER_MOVE_L:Array<String> 	= ["LEFT", "A"];
	public static var KEY_DEFAULT_PLAYER_MOVE_R:Array<String> 	= ["RIGHT", "D"];
	public static var KEY_DEFAULT_TONGUE_OUT:Array<String> 		= ["UP", "W"];
	public static var KEY_DEFAULT_TONGUE_IN:Array<String> 		= ["DOWN", "S"];
	public static var KEY_DEFAULT_AUTOPILOT:Array<String> 		= ["ZERO"];
	public static var KEY_DEFAULT_IMPROV:Array<String> 			= ["I"];
	public static var KEY_DEFAULT_GAMEMODE_L:Array<String> 		= ["LBRACKET"];
	public static var KEY_DEFAULT_GAMEMODE_R:Array<String> 		= ["RBRACKET"];
	public static var KEY_DEFAULT_MUSICMODE_L:Array<String> 	= ["COMMA"];
	public static var KEY_DEFAULT_MUSICMODE_R:Array<String> 	= ["PERIOD"];
	public static var KEY_DEFAULT_HUD:Array<String> 			= ["H"];
	public static var KEY_DEFAULT_RESET:Array<String> 			= ["BACKSLASH"];
	public static var KEY_DEFAULT_PEDALPOINT:Array<String> 		= ["P"];
	public static var KEY_DEFAULT_PENTATONICS:Array<String> 	= ["SLASH"];
	public static var KEY_DEFAULT_SPEEDUP:Array<String> 		= ["CONTROL"];
	public static var KEY_DEFAULT_CHANGEKEY:Array<String> 		= ["K"];
	public static var KEY_DEFAULT_SNOW_LESS:Array<String> 		= ["MINUS"];
	public static var KEY_DEFAULT_SNOW_MORE:Array<String> 		= ["PLUS"];
	public static var KEY_DEFAULT_NOTE_LENGTH:Array<String> 	= ["SHIFT"];
	public static var KEY_DEFAULT_SAVE:Array<String>	 		= ["M"];
	#end
	#if !FLX_NO_GAMEPAD
	public static var ActionsButtons:Array<Array<String>>;
	
	public static var BTN_DEFAULT_PLAYER_MOVE_L:Array<String> 	= ["LEFT_STICK_X_NEG"];
	public static var BTN_DEFAULT_PLAYER_MOVE_R:Array<String> 	= ["LEFT_STICK_X_POS"];
	public static var BTN_DEFAULT_TONGUE_OUT:Array<String> 		= ["LEFT_STICK_Y_NEG"];
	public static var BTN_DEFAULT_TONGUE_IN:Array<String> 		= ["LEFT_STICK_Y_POS"];
	public static var BTN_DEFAULT_AUTOPILOT:Array<String> 		= ["LEFT_STICK_CLICK"];
	public static var BTN_DEFAULT_IMPROV:Array<String> 			= ["RIGHT_STICK_CLICK"];
	public static var BTN_DEFAULT_GAMEMODE_L:Array<String> 		= ["LEFT_TRIGGER"];
	public static var BTN_DEFAULT_GAMEMODE_R:Array<String> 		= ["RIGHT_TRIGGER"];
	public static var BTN_DEFAULT_MUSICMODE_L:Array<String> 	= ["LEFT_SHOULDER"];
	public static var BTN_DEFAULT_MUSICMODE_R:Array<String> 	= ["RIGHT_SHOULDER"];
	public static var BTN_DEFAULT_HUD:Array<String> 			= ["START"];
	public static var BTN_DEFAULT_RESET:Array<String> 			= ["BACK"];
	public static var BTN_DEFAULT_PEDALPOINT:Array<String> 		= ["A"];
	public static var BTN_DEFAULT_PENTATONICS:Array<String> 	= ["B"];
	public static var BTN_DEFAULT_SPEEDUP:Array<String> 		= ["X"];
	public static var BTN_DEFAULT_CHANGEKEY:Array<String> 		= ["Y"];
	public static var BTN_DEFAULT_SNOW_LESS:Array<String> 		= ["DPAD_UP"];
	public static var BTN_DEFAULT_SNOW_MORE:Array<String> 		= ["DPAD_DOWN"];
	public static var BTN_DEFAULT_NOTE_LENGTH:Array<String> 	= ["DPAD_LEFT", "DPAD_RIGHT"];
	public static var BTN_DEFAULT_SAVE:Array<String>	 		= [];
	#end
	
	
	public static function initControls():Void
	{
		//AssetPaths.Controls__cfg
	}
	
	public static function inputPressed(Input:Int):Bool
	{
		var isPressed:Bool = false;
		
		#if !FLX_NO_KEYBOARD
		for (s in ActionsKeys[Input])
		{
			isPressed = isPressed || FlxG.keys.checkStatus(FlxKey.fromString(s), FlxInputState.PRESSED);
		}
		
		#end
		#if !FLX_NO_GAMEPAD
		if (FlxG.gamepads.lastActive != null)
		{
			for (s in ActionsButtons[Input])
			{
				switch (s) 
				{
					case "LEFT_STICK_X_NEG":
						isPressed = isPressed || FlxG.gamepads.lastActive.getXAxis(LEFT_ANALOG_STICK) < 0;
					case "LEFT_STICK_X_POS":
						isPressed = isPressed || FlxG.gamepads.lastActive.getXAxis(LEFT_ANALOG_STICK) > 0;
					case "LEFT_STICK_Y_NEG":
						isPressed = isPressed || FlxG.gamepads.lastActive.getYAxis(LEFT_ANALOG_STICK) < 0;
					case "LEFT_STICK_Y_POS":
						isPressed = isPressed || FlxG.gamepads.lastActive.getYAxis(LEFT_ANALOG_STICK) > 0;
					case "RIGHT_STICK_X_NEG":
						isPressed = isPressed || FlxG.gamepads.lastActive.getXAxis(RIGHT_ANALOG_STICK) < 0;
					case "RIGHT_STICK_X_POS":
						isPressed = isPressed || FlxG.gamepads.lastActive.getXAxis(RIGHT_ANALOG_STICK) > 0;
					case "RIGHT_STICK_Y_NEG":
						isPressed = isPressed || FlxG.gamepads.lastActive.getYAxis(RIGHT_ANALOG_STICK) < 0;
					case "RIGHT_STICK_Y_POS":
						isPressed = isPressed || FlxG.gamepads.lastActive.getYAxis(RIGHT_ANALOG_STICK) > 0;
					default:
						isPressed = isPressed || FlxG.gamepads.lastActive.checkStatus(FlxGamepadInputID.fromString(s), FlxInputState.PRESSED);
				}
			}
		}
		#end
		return isPressed;
		
	}
	
	public static function inputJustPressed(Input:Int):Bool
	{
		var isPressed:Bool = false;
		
		#if !FLX_NO_KEYBOARD
		for (s in ActionsKeys[Input])
		{
			isPressed = isPressed || FlxG.keys.checkStatus(FlxKey.fromString(s), FlxInputState.JUST_PRESSED);
		}
		
		#end
		#if !FLX_NO_GAMEPAD
		if (FlxG.gamepads.lastActive != null)
		{
			for (s in ActionsButtons[Input])
			{
				isPressed = isPressed || FlxG.gamepads.lastActive.checkStatus(FlxGamepadInputID.fromString(s), FlxInputState.JUST_PRESSED);
			}
		}
		#end
		return isPressed;
	}
	
	public static function inputJustReleased(Input:Int):Bool
	{
		var isPressed:Bool = false;
		
		#if !FLX_NO_KEYBOARD
		for (s in ActionsKeys[Input])
		{
			isPressed = isPressed || FlxG.keys.checkStatus(FlxKey.fromString(s), FlxInputState.JUST_RELEASED);
		}
		
		#end
		#if !FLX_NO_GAMEPAD
		if (FlxG.gamepads.lastActive != null)
		{
			for (s in ActionsButtons[Input])
			{
				isPressed = isPressed || FlxG.gamepads.lastActive.checkStatus(FlxGamepadInputID.fromString(s), FlxInputState.JUST_RELEASED);
			}
		}
		#end
		return isPressed;
	}
	
	
}
