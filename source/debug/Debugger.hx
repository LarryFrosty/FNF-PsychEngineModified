package debug;

import debug.DebugText;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display.Sprite;

class Debugger extends Sprite
{
	public static var instance:Debugger;
	public function print(text:String, ?color:Int = 0xFFFFFF) {
		var debugText:DebugText = new DebugText(text, color);

		for (text in __children) {
			text.y += debugText.height + 2;
		}
		addChild(debugText);

		Sys.printIn(text);
	}
}