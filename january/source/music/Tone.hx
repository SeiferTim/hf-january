package music;

import flixel.tweens.FlxTween;
import flixel.system.FlxSound;

class Tone extends FlxSound
{
	public var tween:FlxTween;
	public var tweening:Bool;

	public inline function fadeI(Duration:Float = 1, To:Float = 1):Tone {

		if (!playing)
			play();

		tween = FlxTween.num(0, To, Duration, {onStart:onFadeStart, onComplete:onFadeComplete}, volumeTween);
		return this;
	}

	public inline function fadeO(Duration:Float = 1, ?To:Float = 0):Tone {

		tween = FlxTween.num(this.getActualVolume(), To, Duration, {onStart:onFadeStart, onComplete:onFadeComplete}, volumeTween);
		return this;
	}

	private function onFadeStart(t:FlxTween):Void {

		tweening = true;
	}

	private function onFadeComplete(t:FlxTween):Void {

		tweening = false;
	}
}