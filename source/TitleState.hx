import flixel.ui.FlxButton;

class TitleState extends FlxState
{
	public var button:FlxButton;

	override function create() {
		button = new FlxButton(0, 0, "Click Me");
		button.screenCenter();
		add(button);
	}
}