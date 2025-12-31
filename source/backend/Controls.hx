package backend;

import flixel.input.keyboard.FlxKey;

class Controls
{
	public static var controlBinds:Map<String, FlxKey> = [
		'left' => LEFT,
		'right' => RIGHT,
		'sprint' => SHIFT,
		'interact' => E,
		'jump' => SPACE
	];

	public static function justPressed(key:String) {
		if (FlxG.keys.anyJustPressed([controlBinds[key]])) return true;

		#if android
		// cant be bothered
		switch(key) {
			case 'left': return TouchUtil.justPressed(buttonLeft, camControl);
			case 'right': return TouchUtil.justPressed(buttonRight, camControl);
			case 'sprint': return TouchUtil.justPressed(buttonA, camControl);
			case 'interact': return TouchUtil.justPressed(buttonB, camControl);
			case 'jump': return TouchUtil.justPressed(buttonJump, camControl);
			case _: return false;
		}
		#end
		return false;
	}

	public static function pressed(key:String) {
		if (FlxG.keys.anyPressed([controlBinds[key]])) return true;

		#if android
		// cant be bothered
		switch(key) {
			case 'left': return TouchUtil.pressed(buttonLeft, camControl);
			case 'right': return TouchUtil.pressed(buttonRight, camControl);
			case 'sprint': return TouchUtil.pressed(buttonA, camControl);
			case 'interact': return TouchUtil.pressed(buttonB, camControl);
			case 'jump': return TouchUtil.pressed(buttonJump, camControl);
			case _: return false;
		}
		#end
		return false;
	}

	public static function justReleased(key:String) {
		if (FlxG.keys.anyJustReleased([controlBinds[key]])) return true;

		#if android
		// cant be bothered
		switch(key) {
			case 'left': return TouchUtil.justReleased(buttonLeft, camControl);
			case 'right': return TouchUtil.justReleased(buttonRight, camControl);
			case 'sprint': return TouchUtil.justReleased(buttonA, camControl);
			case 'interact': return TouchUtil.justReleased(buttonB, camControl);
			case 'jump': return TouchUtil.justReleased(buttonJump, camControl);
			case _: return false;
		}
		#end
		return false;
	}

	#if android
	// make them static for now, will change this later
	public static var camControl:FlxCamera;
	public static var buttonLeft:FlxSprite;
	public static var buttonRight:FlxSprite;
	public static var buttonA:FlxSprite;
	public static var buttonB:FlxSprite;
	public static var buttonJump:FlxSprite;

	public static function setupMobileControls() {
		if (FlxG.cameras.list.contains(camControl)) FlxG.cameras.remove(camControl);

		camControl = new FlxCamera();
		camControl.bgColor.alpha = 0;
		FlxG.cameras.add(camControl, false);

		buttonLeft = new FlxSprite(50, 500).makeGraphic(150, 150, 0xFF0000FF);
		buttonLeft.camera = camControl;
		buttonLeft.alpha = 0.6;
		FlxG.state.add(buttonLeft);

		buttonRight = new FlxSprite(250, 500).makeGraphic(150, 150, 0xFF00FF00);
		buttonRight.camera = camControl;
		buttonRight.alpha = 0.6;
		FlxG.state.add(buttonRight);

		buttonA = new FlxSprite(900, 500).makeGraphic(150, 150, 0xFFFFFF00);
		buttonA.camera = camControl;
		buttonA.alpha = 0.6;
		FlxG.state.add(buttonA);

		buttonB = new FlxSprite(1000, 300).makeGraphic(150, 150, 0xFF00FFFF);
		buttonB.camera = camControl;
		buttonB.alpha = 0.6;
		FlxG.state.add(buttonB);

		buttonJump = new FlxSprite(1100, 500).makeGraphic(150, 150, 0xFFFF00FF);
		buttonJump.camera = camControl;
		buttonJump.alpha = 0.6;
		FlxG.state.add(buttonJump);
	}
	#end
}

class TouchUtil
{
	public static function justPressed(object:FlxSprite, ?camera:FlxCamera) {
		for (touch in FlxG.touches.list) {
			if (touch.overlaps(object, camera) && touch.justPressed) return true;
		}
		return false;
	}

	public static function pressed(object:FlxSprite, ?camera:FlxCamera) {
		for (touch in FlxG.touches.list) {
			if (touch.overlaps(object, camera) && touch.pressed) return true;
		}
		return false;
	}

	public static function justReleased(object:FlxSprite, ?camera:FlxCamera) {
		for (touch in FlxG.touches.list) {
			if (touch.overlaps(object, camera) && touch.justReleased) return true;
		}
		return false;
	}
}