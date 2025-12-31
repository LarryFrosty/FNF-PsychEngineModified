class Enemy extends FlxSprite
{
	public var idleTimer:Float = 0;
	public var direction:Int = 0;
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		makeGraphic(50, 50, 0xFFFF0000);
		acceleration.y = 1400;
	}

	override function update(elapsed:Float) {
		if (idleTimer <= 0) {
			if (FlxG.random.bool(95)) {
				direction = FlxG.random.int(0, 1);
				velocity.x = direction == 0 ? -100 : 100;
			}
			else {
				velocity.x = 0;
			}
			idleTimer = FlxG.random.float(0.5, 2);
		}
		else idleTimer -= elapsed;
	}
}