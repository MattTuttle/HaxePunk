package haxepunk.assets;

#if macro
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

import haxe.io.Path;
import haxe.ds.StringMap;

typedef PreloadPath = {
	path:String,
	?alias:String
}

class Preloader
{
	public var required(default, null):Int = 0;
	public var loaded(default, null):Int = 0;
	public var failed(default, null):Int = 0;

	var onload:Void->Void;

	public function new()
	{
	}

	public function addAsset(path:String, ?aliases:Array<String>)
	{
		assets.set(path, [path].concat(aliases == null ? [] : aliases));
	}

	function check() {
		if (required == loaded + failed)
			onload();
	}

	function success() {
		loaded += 1;
		check();
	}

	function fail() {
		failed += 1;
		check();
	}

	#if !macro
	function loadTexture(path:String)
	{
		var aliases = assets.get(path);
		#if (!lime && js)
		haxepunk.backend.html5.Texture.loadFromURL(path).then(function(texture) {
			for (alias in aliases) {
				haxepunk.assets.AssetCache.global.addTexture(alias, texture);
			}
			success();
		}, function(_) {
			fail();
		});
		#else
		var texture = haxepunk.HXP.assetLoader.getTexture(path);
		if (texture == null)
		{
			fail();
		}
		else
		{
			for (alias in aliases) {
				haxepunk.assets.AssetCache.global.addTexture(alias, texture);
			}
			success();
		}
		#end
	}

	function loadSound(path:String)
	{
		var aliases = assets.get(path);
		#if (!lime && js)
		haxepunk.backend.html5.Sound.loadFromURL(path).then(function(sound) {
			for (alias in aliases) {
				haxepunk.assets.AssetCache.global.addSound(alias, sound);
			}
			success();
		}, function(_) {
			fail();
		});
		#else
		var sound = HXP.assetLoader.getSound(path);
		if (sound == null)
		{
			fail();
		}
		else
		{
			for (alias in aliases) {
				haxepunk.assets.AssetCache.global.addSound(alias, sound);
			}
			success();
		}
		#end
	}
	#end

	public function load(onload:Void->Void)
	{
		#if !macro
		this.onload = onload;
		for (path in assets.keys())
		{
			required += 1;
			switch (Path.extension(path))
			{
				case "jpg", "jpeg", "png":
					loadTexture(path);
				case "mp3", "ogg", "wav":
					loadSound(path);
			}
		}
		#end
	}

	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var found = false;
		// search for @:preload metadata on functions
		for (field in fields)
		{
			switch (field.kind)
			{
				case FFun(f):
					for (meta in field.meta)
					{
						if (meta.name == ":preload")
						{
							var preloadBlocks = [for (param in meta.params) preload(parseMetaPath(param))];
							// wrap the function block with the preloader code
							f.expr = macro {
								$b{preloadBlocks};
								_preloader.load(function() {
									${f.expr};
								});
							};
							found = true;
						}
					}
				default:
			}
		}
		// add `var _preloader:Preloader;` field when there is a @:preload function
		if (found) {
			fields.push({
				name: '_preloader',
				pos: Context.currentPos(),
				kind: FieldType.FVar(macro : haxepunk.assets.Preloader, macro new haxepunk.assets.Preloader())
			});
		}
		return fields;
	}

	#if macro
	static function getString(expr:Expr):String {
		return switch (expr.expr) {
			case EConst(CString(str, _)):
				str;
			default:
				throw "Expected string";
		}
	}

	static function parseMetaPath(expr:Expr):PreloadPath {
		return switch (expr.expr) {
			case EConst(CString(str, _)):
				var parts = str.split(":");
				if (parts.length == 2)
				{
					{ path: parts[0], alias: parts[1] };
				}
				else
				{
					{ path: str };
				}
			case EArrayDecl(v):
				if (v.length == 2) {
					{ path: getString(v[0]), alias: getString(v[1]) };
				} else {
					throw "There should only be 2 values in the preloader array";
				}
			default:
				throw "Invalid preloader path";
		};
	}

	static function preload(preloadPath:PreloadPath):Expr {
		var search = [preloadPath.path];
		var iterations = 0;
		var exprs = [];
		while (iterations < 1000 && search.length > 0)
		{
			var path = search.pop();
			if (FileSystem.exists(path))
			{
				if (FileSystem.isDirectory(path))
				{
					for (item in FileSystem.readDirectory(path))
					{
						var from = Path.join([path, item]);
						search.push(from);
					}
				}
				else
				{
					var aliases = [];
					if (preloadPath.alias != null)
					{
						aliases.push(StringTools.replace(path, preloadPath.path, preloadPath.alias));
					}
					exprs.push(macro _preloader.addAsset($v{path}, $v{aliases}));
				}
			}
			iterations += 1;
		}

		return macro $b{exprs};
	}
	#end

	var assets = new StringMap<Array<String>>();
}
