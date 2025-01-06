package backend;

import flixel.util.FlxGradient;
import flixel.FlxSubState;

class CustomFadeTransition extends FlxSubState {
	public static var finishCallback:Void->Void;
	static var transitionImages:Array<String> = ['baldiplier', 'markiplier', 'hooh', 'cat'];
	static var image:String;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
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
		if(!isTransIn && ClientPrefs.data.customTransition)
			image = transitionImages[FlxG.random.int(0, transitionImages.length - 1, [transitionImages.indexOf(image)])];

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		if(ClientPrefs.data.customTransition)
		{
			transSprite = new FlxSprite(Paths.image('transition/$image'));
			transSprite.setGraphicSize(width, height);
			transSprite.updateHitbox();
			transSprite.scrollFactor.set();
			transSprite.screenCenter(X);
			add(transSprite);

			if(!isTransIn)
				transSprite.y = -transSprite.height;
		}
		else
		{
			transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
			transGradient.scale.x = width;
			transGradient.updateHitbox();
			transGradient.scrollFactor.set();
			transGradient.screenCenter(X);
			add(transGradient);

			transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			transBlack.scale.set(width, height + 400);
			transBlack.updateHitbox();
			transBlack.scrollFactor.set();
			transBlack.screenCenter(X);
			add(transBlack);

			if(isTransIn)
				transGradient.y = transBlack.y - transBlack.height;
			else
				transGradient.y = -transGradient.height;
		}

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(ClientPrefs.data.customTransition) updateCustom(elapsed);
		else updateNormal(elapsed);
	}

	function updateNormal(elapsed:Float)
	{
		var height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		var targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
		if(duration > 0)
			transGradient.y += (height + targetPos) * elapsed / duration;
		else
			transGradient.y = (targetPos) * elapsed;

		if(isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;

		if(transGradient.y >= targetPos)
		{
			close();
		}
	}

	function updateCustom(elapsed:Float)
	{
		var height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		var targetPos:Float = !isTransIn ? 0 : transSprite.height + 50 * Math.max(camera.zoom, 0.001);
		if(duration > 0)
			transSprite.y += (height + targetPos) * elapsed / duration;
		else
			transSprite.y = (targetPos) * elapsed;

		if(transSprite.y > 0 && !isTransIn) transSprite.y = 0;
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
