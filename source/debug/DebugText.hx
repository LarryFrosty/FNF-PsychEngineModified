package debug;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Assets;

class DebugText extends TextField
{
	public var disableTime:Float = 6;
	public function new(newText:String, color:Int) {
		super();
		defaultTextFormat = new TextFormat(Assets.getFont(Paths.font('vcr.ttf')).fontName, 28, color);
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

	// might not work as intended i have no idea how enterFrame works lol
	override function __enterFrame(deltaTime:Float) {
		disableTime -= deltaTime;
		if(disableTime < 0) disableTime = 0;
		if(disableTime < 1) alpha = disableTime;
	}
}