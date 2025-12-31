import flixel.util.FlxGradient;
import flixel.util.FlxDirectionFlags;
import flixel.ui.FlxBar;
import backend.Controls;

class PlayState extends FlxState
{
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	public var wall:FlxSprite;
	public var ground:FlxSprite;
	public var sky:FlxSprite;

	public var player:Player;
	public var enemy:Enemy;

	public var staminaBar:FlxBar;
	override function create() {
		camGame = new FlxCamera();
		camGame.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		Controls.setupMobileControls();

		FlxG.worldBounds.set(FlxG.width*2, FlxG.height);

		sky = FlxGradient.createGradientFlxSprite(FlxG.width*2, FlxG.height, [0xFFD4F3FF, 0xFF318CFF]);
		add(sky);

		enemy = new Enemy(500, 350);
		add(enemy);

		player = new Player(200, 150);
		add(player);

		FlxG.camera.followLerp = 0.7;
		FlxG.camera.target = player;
		FlxG.camera.minScrollX = 0;
		FlxG.camera.minScrollY = 0;
		FlxG.camera.maxScrollY = 720;

		wall = new FlxSprite().makeGraphic(100, 600, 0xFFF1F1F1);
		wall.immovable = true;
		add(wall);

		ground = new FlxSprite().makeGraphic(FlxG.width*2, 250, 0xFFF1F1F1);
		ground.y = FlxG.height - ground.height;
		ground.immovable = true;
		add(ground);

		staminaBar = new FlxBar(Controls.buttonA.x, Controls.buttonA.y, null, Std.int(Controls.buttonA.width), 10, player, 'stamina', 0, player.maxStamina);
		staminaBar.camera = Controls.camControl;
		staminaBar.alpha = 0;
		add(staminaBar);

		super.create();
	}

	override function update(elapsed:Float) {
		collideEntities();

		if (FlxG.collide(enemy, wall)) enemy.velocity.x *= -1;

		if (player.sprinting) {
			if (Controls.buttonA.alpha != 0.6) Controls.buttonA.alpha = 0.6;
			if (staminaBar.alpha != 1) staminaBar.alpha = 1;
		}
		else {
			if (Controls.buttonA.alpha != 1) Controls.buttonA.alpha = 1;
		}

		if (staminaBar.value >= 100 && staminaBar.alpha == 1) {
			FlxTween.cancelTweensOf(staminaBar);
			FlxTween.tween(staminaBar, { alpha: 0 }, 0.25);
		}

		if (player.attacking && player.attackCooldown && FlxG.overlap(player, enemy)) {
			enemy.health -= 0.25;
			if (enemy.health <= 0) enemy.kill();
			player.attackCooldown = false;
		}

		super.update(elapsed);
	}

	function collideEntities() {
		for (spr in [wall, ground]) {
			FlxG.collide(player, spr);
			FlxG.collide(enemy, spr);
		}
	}
}