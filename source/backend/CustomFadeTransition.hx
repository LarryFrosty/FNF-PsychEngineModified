package backend;

import flixel.util.FlxGradient;
import flixel.FlxSubState;

class CustomFadeTransition extends FlxSubState {
	public static var finishCallback:Void->Void;
	static var transitionImages:Array<String> = ['markiplier'];
	static var image:String;
	var isTransIn:Bool = false;
	var transSprite:FlxSprite;

	var duration:Float;
	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		if (!isTransIn)
			image = transitionImages[FlxG.random.int(0, transitionImages.length - 1, [transitionImages.indexOf(image)])];

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		transSprite = new FlxSprite(Paths.image('transition/$image'));
		transSprite.setGraphicSize(width, height);
		transSprite.updateHitbox();
		transSprite.scrollFactor.set();
		transSprite.screenCenter(X);
		add(transSprite);

		if(!isTransIn)
			transSprite.y = -transSprite.height;

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transSprite.height + 50 * Math.max(camera.zoom, 0.001);
		if(duration > 0)
			transSprite.y += (height + targetPos) * elapsed / duration;
		else
			transSprite.y = (targetPos) * elapsed;

		if(transSprite.y >= targetPos)
		{
			close();
		}
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
