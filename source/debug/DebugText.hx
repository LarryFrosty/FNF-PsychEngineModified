package debug;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Assets;

class DebugText extends TextField
{
	public var disableTime:Float = 6;
	public function new(newText:String, color:Int) {
		super();
		defaultTextFormat = new TextFormat(Assets.getFont(Paths.font('vcr.ttf')).fontName, 24, color);
		width = FlxG.width - 20;
		wordWrap = true;
		multiline = true;
		selectable = false;
		embedFonts = true;
		sharpness = 100;
		autoSize = LEFT;
		text = newText;
		scaleX = scaleY = 1;
		x = FlxG.game.x + 10;
		y = FlxG.game.y + 10;
	}

	override function __enterFrame(deltaTime:Int) {
		@:privateAccess
		if (!FlxG.game._lostFocus || !FlxG.autoPause) {
			disableTime -= deltaTime / 1000;
			if (disableTime < 1) alpha = disableTime;
			if (disableTime < 0 || y >= FlxG.height * 2) parent?.removeChild(this);
		}
		super.__enterFrame(deltaTime);
	}
}