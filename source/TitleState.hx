import flixel.ui.FlxButton;

class TitleState extends FlxState
{
	public var button:FlxButton;

	override function create() {
		button = new FlxButton(0, 0, "Start", ()->FlxG.switchState(new PlayState()));
		button.scale.set(3, 3);
		button.updateHitbox();
		button.screenCenter();
		add(button);
	}
}