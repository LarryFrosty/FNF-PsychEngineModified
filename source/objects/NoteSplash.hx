package objects;

import backend.animation.PsychAnimationController;
import shaders.RGBPalette;
import states.editors.NoteSplashEditorState;
import flixel.system.FlxAssets.FlxShader;

private typedef RGB = {
	r:Null<Int>,
	g:Null<Int>,
	b:Null<Int>
}

private typedef NoteSplashAnim = {
	name:String,
	noteData:Int,
	prefix:String,
	indices:Array<Int>,
	offsets:Array<Float>,
	fps:Array<Int>
}

typedef NoteSplashConfig = {
	animations:Map<String, NoteSplashAnim>,
	scale:Float,
	allowRGB:Bool,
	allowPixel:Bool,
	rgb:Array<Null<RGB>>
}

class NoteSplash extends FlxSprite
{
	public var rgbShader:PixelSplashShaderRef;
	public var texture:String;
	public var config(default, set):NoteSplashConfig;
	public var babyArrow:StrumNote;

	var noteDataMap:Map<Int, String> = new Map();

	public static var defaultNoteSplash(default, never):String = "noteSplashes/noteSplashes";
	public static var configs:Map<String, NoteSplashConfig> = new Map();

	public function new(?x:Float = 0, ?y:Float = 0, ?splash:String)
	{
		super(x, y);

        animation = new PsychAnimationController(this);

		rgbShader = new PixelSplashShaderRef();
		shader = rgbShader.shader;

		loadSplash(splash);
	}

	var maxAnims:Int = 0;
	public function loadSplash(?splash:String)
	{
		maxAnims = 0;

		texture = splash;
		frames = Paths.getSparrowAtlas(texture);
		if (frames == null)
		{
			texture = defaultNoteSplash + getSplashSkinPostfix();
			frames = Paths.getSparrowAtlas(texture);
			if (frames == null)
			{
				texture = defaultNoteSplash;
				frames = Paths.getSparrowAtlas(texture);
			}
		}

		var path:String = 'images/$texture';
		if (configs.exists('$path.json')) this.config = configs.get('$path.json');
		else if (Paths.fileExists('$path.json', TEXT))
		{
			var config:Dynamic = haxe.Json.parse(Paths.getTextFromFile('$path.json'));
			if (config != null)
			{
				var tempConfig:NoteSplashConfig = {
					animations: new Map(),
					scale: config.scale,
					allowRGB: config.allowRGB,
					allowPixel: config.allowPixel,
					rgb: config.rgb
				}

				for (i in Reflect.fields(config.animations))
				{
					tempConfig.animations.set(i, Reflect.field(config.animations, i));
				}

				this.config = tempConfig;
				configs.set('$path.json', this.config);
			}
		}
		else
		{
			var oldConfig:Dynamic = parseTxt(path) ?? {anim: 'note splash', fps: [22, 26], offsets: [[0, 0]]}
			var animName:String = oldConfig.anim;
			var failedToFind:Bool = false;
			while (true)
			{
				for (v in Note.colArray)
				{
					if (!checkForAnim('$animName $v ${maxAnims+1}'))
					{
						failedToFind = true;
						break;
					}
				}
				if (failedToFind) break;
				maxAnims++;
			}

			var tempConfig:NoteSplashConfig = createConfig();
			for (animNum in 0...maxAnims)
			{
				for (i => col in Note.colArray)
				{
					var data:Int = i % Note.colArray.length + (animNum * Note.colArray.length); 
					var offsets:Array<Float> = oldConfig.offsets[FlxMath.wrap(data, 0, Std.int(oldConfig.offsets.length-1))];
					var anim:String = animNum > 0 ? col + (animNum+1) : col;
					addAnimationToConfig(tempConfig, 1, anim, '$animName $col ${animNum+1}', oldConfig.fps, offsets, [], data);
				}
			}

			this.config = tempConfig;
			configs.set('$path.json', config);
		}
	}

	public function spawnSplashNote(?x:Float = 0, ?y:Float = 0, ?noteData:Int = 0, ?note:Note, ?randomize:Bool = true)
	{
		if (note != null && note.noteSplashData.disabled)
			return;

		var loadedTexture:String = defaultNoteSplash + getSplashSkinPostfix();
		if (note != null && note.noteSplashData.texture != null) loadedTexture = note.noteSplashData.texture;
		else if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) loadedTexture = PlayState.SONG.splashSkin;

		loadSplash(loadedTexture);
		setPosition(x, y);

		if (babyArrow != null)
			setPosition(babyArrow.x, babyArrow.y); // To prevent it from being misplaced for one game tick

		if (note != null)
			noteData = note.noteData;

		if (randomize)
		{
			var animArray:Array<Int> = [];

			for (i in 0...maxAnims)
			{
				var data:Int = noteData % Note.colArray.length + (i * Note.colArray.length); 

				if (!animArray.contains(data))
					animArray.push(data);
			}

			if (animArray.length > 1)
				noteData = animArray[FlxG.random.int(0, animArray.length-1)];
		}

		this.noteData = noteData;
		var anim:String = playDefaultAnim();

		var tempShader:RGBPalette = null;
		var inEditor:Bool = (cast FlxG.state) is NoteSplashEditorState;
		if (inEditor || (note == null || note.noteSplashData.useRGBShader) && (PlayState.SONG == null || !PlayState.SONG.disableNoteRGB))
		{
			Note.initializeGlobalRGBShader(noteData % Note.colArray.length);
			// If Note RGB is enabled:
			if((note != null && !note.noteSplashData.useGlobalShader) || inEditor)
			{
				tempShader = new RGBPalette();
				var colors = config.rgb;
				if (config.allowRGB && colors != null)
				{
					for (i in 0...colors.length)
					{
						if (i > 2) break;

						var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData % Note.colArray.length];
						if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[noteData % Note.colArray.length];

						var rgb = colors[i];
						if (rgb == null)
						{
							if (i == 0) tempShader.r = arr[0];
							else if (i == 1) tempShader.g = arr[1];
							else if (i == 2) tempShader.b = arr[2];
							continue;
						}

						var r:Null<Int> = rgb.r; 
						var g:Null<Int> = rgb.g;
						var b:Null<Int> = rgb.b;

						if (r == null || Math.isNaN(r) || r < 0) r = arr[0];
						if (g == null || Math.isNaN(g) || g < 0) g = arr[1];
						if (b == null || Math.isNaN(b) || b < 0) b = arr[2];

						var color:FlxColor = FlxColor.fromRGB(r, g, b);
						if (i == 0) tempShader.r = color;
						else if (i == 1) tempShader.g = color;
						else if (i == 2) tempShader.b = color;
					} 
				}
				else tempShader = Note.globalRgbShaders[noteData % Note.colArray.length];

				if (note.noteSplashData.r != -1) tempShader.r = note.noteSplashData.r;
				if (note.noteSplashData.g != -1) tempShader.g = note.noteSplashData.g;
				if (note.noteSplashData.b != -1) tempShader.b = note.noteSplashData.b;
			}
			else tempShader = Note.globalRgbShaders[noteData % Note.colArray.length];
		}
		rgbShader.copyValues(tempShader);

		if(!config.allowPixel) rgbShader.pixelAmount = 1;

		var conf = config.animations.get(anim);
		var offsets = conf?.offsets ?? null;
		if(offsets != null) offset.set(offsets[0], offsets[1]);
		//else offset.set(10, 10);

		animation.finishCallback = function(name:String) {
			kill();
		};
		
        alpha = ClientPrefs.data.splashAlpha;
		if(note != null) alpha = note.noteSplashData.a;

		if(note != null) antialiasing = note.noteSplashData.antialiasing;
		if(PlayState.isPixelStage || !ClientPrefs.data.antialiasing) antialiasing = false;

		var minFps:Int = 22;
		var maxFps:Int = 26;
		if(conf != null)
		{
			minFps = conf.fps[0];
			if (minFps < 0) minFps = 0;

			maxFps = conf.fps[1];
			if (maxFps < 0) maxFps = 0;
		}

		if(animation.curAnim != null)
			animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
	}
	
	public var noteData:Int = 0;
	public function playDefaultAnim()
	{
		var animData:String = noteDataMap.get(noteData);
		if (animData != null && animation.exists(animData))
			animation.play(animData, true);
		else
			visible = false;
		return animData;
	}

	function checkForAnim(anim:String)
	{
		var animFrames = [];
		@:privateAccess
		animation.findByPrefix(animFrames, anim); // adds valid frames to animFrames

		return animFrames.length > 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (babyArrow != null)
		{
			//cameras = babyArrow.cameras;
			setPosition(babyArrow.x, babyArrow.y);
		}
	}

    public static function getSplashSkinPostfix()
	{
		var skin:String = '';
		if(ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin)
			skin = '-' + ClientPrefs.data.splashSkin.trim().toLowerCase().replace(' ', '-');
		return skin;
	}

	public static function createConfig():NoteSplashConfig
	{
		return {
			animations: new Map(),
			scale: 1,
			allowRGB: true,
			allowPixel: true,
			rgb: null
		}
	}

	public static function parseTxt(skin:String)
	{
		var path:String = Paths.getPath('$skin.txt', TEXT);
		var configFile:Array<String> = CoolUtil.coolTextFile(path);
		if(configFile.length < 1) return null;
		
		var framerates:Array<String> = configFile[1].split(' ');
		var offs:Array<Array<Float>> = [];
		for (i in 2...configFile.length)
		{
			var animOffs:Array<String> = configFile[i].split(' ');
			offs.push([Std.parseFloat(animOffs[0]), Std.parseFloat(animOffs[1])]);
		}

		var config:Dynamic = {
			anim: configFile[0],
			fps: [Std.parseInt(framerates[0]), Std.parseInt(framerates[1])],
			offsets: offs
		};
		return config;
	}

	public static function addAnimationToConfig(config:NoteSplashConfig, scale:Float, name:String, prefix:String, fps:Array<Int>, offsets:Array<Float>, indices:Array<Int>, noteData:Int):NoteSplashConfig
	{
		if (config == null) config = createConfig();

		config.animations.set(name, {name: name, noteData: noteData, prefix: prefix, indices: indices, offsets: offsets, fps: fps});
		config.scale = scale;
		return config;
	}

	function set_config(value:NoteSplashConfig):NoteSplashConfig 
	{
		if (value == null) value = createConfig();

		noteDataMap.clear();

		for (i in value.animations)
		{
			var key:String = i.name;
			if (i.prefix.length > 0 && key != null && key.length > 0)
			{
				if (i.indices != null && i.indices.length > 0)
					animation.addByIndices(key, i.prefix, i.indices, "", i.fps[1], false);
				else
					animation.addByPrefix(key, i.prefix, i.fps[1], false);

				noteDataMap.set(i.noteData, key);
			}
		}

		scale.set(value.scale, value.scale);
		return config = value;
	}
}

class PixelSplashShaderRef 
{
	public var shader:PixelSplashShader = new PixelSplashShader();
	public var enabled(default, set):Bool = true;
	public var pixelAmount(default, set):Float = 1;

	public function copyValues(tempShader:RGBPalette)
	{
		if(tempShader != null)
		{
			for (i in 0...3)
			{
				shader.r.value[i] = tempShader.shader.r.value[i];
				shader.g.value[i] = tempShader.shader.g.value[i];
				shader.b.value[i] = tempShader.shader.b.value[i];
			}
			shader.mult.value[0] = tempShader.shader.mult.value[0];
		}
		else enabled = false;
	}

	public function set_enabled(value:Bool)
	{
		enabled = value;
		shader.mult.value = [value ? 1 : 0];
		return value;
	}

	public function set_pixelAmount(value:Float)
	{
		pixelAmount = value;
		shader.uBlocksize.value = [value, value];
		return value;
	}

	public function reset()
	{
		shader.r.value = [0, 0, 0];
		shader.g.value = [0, 0, 0];
		shader.b.value = [0, 0, 0];
	}

	public function new()
	{
		reset();
		enabled = true;

		if (PlayState.isPixelStage) pixelAmount = PlayState.daPixelZoom;
		//trace('Created shader ' + Conductor.songPosition);
	}
}

class PixelSplashShader extends FlxShader
{
	@:glFragmentHeader('
		#pragma header

		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;
		uniform vec2 uBlocksize;

		vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 coord) {
			vec2 blocks = openfl_TextureSize / uBlocksize;
			vec4 color = flixel_texture2D(bitmap, floor(coord * blocks) / blocks);
			if (!hasTransform) {
				return color;
			}

			if(color.a == 0.0 || mult == 0.0) {
				return color * openfl_Alphav;
			}

			vec4 newColor = color;
			newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
			newColor.a = color.a;

			color = mix(color, newColor, mult);

			if(color.a > 0.0) {
				return vec4(color.rgb, color.a);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}')

	@:glFragmentSource('
		#pragma header

		void main() {
			gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
		}')

	public function new()
	{
		super();
	}
}
