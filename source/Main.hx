package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

// // // // // // // // //
class Main extends Sprite
{
	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}

	public function new()
	{
		super();
		#if mobile
		Sys.setCwd(haxe.io.Path.addTrailingSlash(AndroidContext.getExternalFilesDir()));
		#end

		FlxG.save.bind('gametest', 'gametest');

		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
	}
}
