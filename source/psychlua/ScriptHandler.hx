package psychlua;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end
import psychlua.LuaUtils;

#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end

typedef ReturnValue = {
	var luaValue:Dynamic;
	var hscriptValue:Dynamic;
}

class ScriptHandler
{
	public static var luaExtensions:Array<String> = ['.lua'];
	public static var hscriptExtensions:Array<String> = ['.hx', '.hscript', '.hxs', '.hxc', '.haxe'];

	public static function init() {
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/')) {
			for (file in Paths.readDirectory(folder)) {
				#if LUA_ALLOWED
				if(ScriptHandler.findExtension(file))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(ScriptHandler.findExtension(file, true))
					new HScript(null, folder + file);
				#end
			}
		}

		FlxG.signals.postStateSwitch.add(function() {
			ScriptHandler.callOnLuas('onStateSwitch', [Type.getClassName(Type.getClass(FlxG.state))]);
			ScriptHandler.callOnHScript('onStateSwitch', [FlxG.state]);
		});
		#end
	}

	public static function addScript(file:String, ext:String = '.lua') {
		var path:String = findScript(file, ext);
		#if MODS_ALLOWED
		if(FileSystem.exists(path))
		#else
		if(Assets.exists(path, TEXT))
		#end
		{
			#if LUA_ALLOWED
			if (findExtension(path)) {
				new FunkinLua(path);
			}
			#end
			#if HSCRIPT_ALLOWED
			if (findExtension(path, true)) {
				new HScript(path);
			}
			#end
		}
	}

	public static function removeScript(file:String, ext:String = '.lua') {
		var path:String = findScript(file, ext);
		#if MODS_ALLOWED
		if(FileSystem.exists(path))
		#else
		if(Assets.exists(path, TEXT))
		#end
		{
			#if LUA_ALLOWED
			for (lua in FunkinLua.curScripts) {
				if (lua.scriptName == path) {
					lua.stop();
				}
			}
			#end
			#if HSCRIPT_ALLOWED
			for (hscript in HScript.curScripts) {
				if (hscript.origin == path) {
					hscript.destroy();
				}
			}
			#end
		}
	}

	public static function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):ReturnValue {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:ReturnValue = {luaValue: returnVal, hscriptValue: returnVal}
		#if LUA_ALLOWED
		result.luaValue = ScriptHandler.callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		#end
		#if HSCRIPT_ALLOWED
		result.hscriptValue = ScriptHandler.callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		#end
		return result;
	}

	public static function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		ScriptHandler.setOnLuas(variable, arg, exclusions);
		ScriptHandler.setOnHScript(variable, arg, exclusions);
	}

	public static function findScript(file:String, ext:String = '.lua') {
		if(!file.endsWith(ext)) file += ext;
		var path:String = Paths.getPath('scripts/$file', TEXT);
		#if MODS_ALLOWED
		if(FileSystem.exists(path))
		#else
		if(Assets.exists(path, TEXT))
		#end
		{
			return path;
		}
		path = Paths.getPath(file, TEXT);
		#if MODS_ALLOWED
		if(FileSystem.exists(path))
		#else
		if(Assets.exists(path, TEXT))
		#end
		{
			return path;
		}
		#if MODS_ALLOWED
		else if(FileSystem.exists(file))
		#else
		else if(Assets.exists(file, TEXT))
		#end
		{
			return file;
		}
		return null;
	}

	public static function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		#if LUA_ALLOWED
		var arr:Array<FunkinLua> = [];
		for (script in FunkinLua.curScripts)
		{
			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;
		}
		#end
		return returnVal;
	}

	public static function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		#if LUA_ALLOWED
		for (script in FunkinLua.curScripts) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public static function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		#if HSCRIPT_ALLOWED
		for (script in HScript.curScripts) {
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var callValue = script.call(funcToCall, args);
			if(callValue != null)
			{
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
		}
		#end
		return returnVal;
	}

	public static function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		#if HSCRIPT_ALLOWED
		for (script in HScript.curScripts) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public static function findExtension(path:String, isHaxe:Bool = false) {
		if (isHaxe) return hscriptExtensions.contains(path.substring(path.lastIndexOf('.')));
		else return luaExtensions.contains(path.substring(path.lastIndexOf('.')));
	}
}