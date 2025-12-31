import backend.Controls;

class Player extends FlxSprite
{
	public var sprinting:Bool = false;
	public var sprintingCooldown:Bool = false;
	public var maxStamina:Float = 100;
	public var stamina:Float = maxStamina;
	public var attacking:Bool = false;
	public var attackCooldown:Bool = false;
	var attackTimer:FlxTimer;
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		frames = FlxAtlasFrames.fromSparrow('assets/images/stick.png', File.getContent('assets/images/stick.xml'));
		animation.addByPrefix('idle', 'idle', 6);
		animation.addByPrefix('walk', 'walk', 6);
		animation.addByPrefix('run', 'walk', 12);
		animation.addByPrefix('attack', 'attack', 6);
		scale.set(0.35, 0.35);
		updateHitbox();
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
		offset.y -= 65;
		acceleration.y = 1400;
		drag.x = 1800;
	}

	override function update(elapsed:Float) {
		if (isTouching(DOWN) && Controls.justPressed('jump')) {
			velocity.y = -600;
		}

		if (Controls.pressed('left')) {
			if (!attacking) {
				velocity.x = sprinting ? -300 : -200;
				animation.play(sprinting ? 'run' : 'walk');
			}
			facing = LEFT;
	 	}
		else if (Controls.pressed('right')) {
			if (!attacking) {
				velocity.x = sprinting ? 300 : 200;
				animation.play(sprinting ? 'run' : 'walk');
			}
			facing = RIGHT;
		}
		else if (!attacking) {
			player.animation.play('idle');
		}

		if (Controls.justPressed('sprint') && !sprintCooldown) {
			sprinting = !sprinting;
			Controls.buttonA.alpha = sprinting ? 1.0 : 0.6;
		}
		if (sprinting) {
			stamina -= 25 * elapsed;
		}
		else if (stamina != maxStamina) {
			stamina = FlxMath.bound(stamina + 30 * elapsed, 0, maxStamina);
			if (stamina >= 30) sprintCooldown = false;
		}

		if (stamina <= 0 && sprinting) {
			sprinting = false;
			sprintCooldown = true;
			Controls.buttonA.alpha = 0.6;
		}

		if (Controls.justPressed('interact') && !attackCooldown) {
			velocity.x += facing == LEFT ? -600 : 600;
			animation.play('attack');
			attacking = true;
			attackCooldown = true;
			attackTimer?.cancel();
			attackTimer = new FlxTimer().start(0.3, ()->{
				attacking = false;
				attackCooldown = false;
				attackTimer = null;
			});
		}

		super.update(elapsed);
	}
}