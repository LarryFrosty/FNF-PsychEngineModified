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
}