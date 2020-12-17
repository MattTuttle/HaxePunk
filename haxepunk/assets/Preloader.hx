package haxepunk.assets;

#if macro
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.Compiler;
#end

import haxe.io.Path;
import haxe.ds.StringMap;

typedef PreloadPath = {
	path:String,
	?alias:String,
	?extensions:Array<String>
}

class Preloader
{
	#if !macro

	public var required(default, null):Int = 0;
	public var loaded(default, null):Int = 0;
	public var failed(default, null):Int = 0;

	var cache:AssetCache;
	public var onLoad = new haxepunk.Signal.Signal0();
	var assets = new StringMap<Array<String>>();

	public function new(?cache:AssetCache)
	{
		if (cache == null)
		{
			cache = haxepunk.assets.AssetCache.global;
		}
		this.cache = cache;
	}

	public function addAsset(path:String, ?aliases:Array<String>)
	{
		required += 1;
		assets.set(path, [path].concat(aliases == null ? [] : aliases));
	}

	function check()
	{
		if (required == loaded + failed)
			onLoad.invoke();
	}

	function success()
	{
		loaded += 1;
		check();
	}

	function fail()
	{
		failed += 1;
		check();
	}

	function loadTexture(path:String)
	{
		var aliases = assets.get(path);
		#if (!lime && js)
		haxepunk.backend.html5.Texture.loadFromURL(path).then(function(texture) {
			for (alias in aliases) {
				cache.addTexture(alias, texture);
			}
			success();
		}, function(_) {
			fail();
		});
		#else
		var texture = AssetCache.assetLoader.getTexture(path);
		if (texture == null)
		{
			Log.critical('Failed to load texture: ${path}');
			fail();
		}
		else
		{
			for (alias in aliases) {
				cache.addTexture(alias, texture);
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
				cache.addSound(alias, sound);
			}
			success();
		}, function(_) {
			fail();
		});
		#else
		var sound = AssetCache.assetLoader.getSound(path);
		if (sound == null)
		{
			Log.critical('Failed to load sound: ${path}');
			fail();
		}
		else
		{
			for (alias in aliases) {
				cache.addSound(alias, sound);
			}
			success();
		}
		#end
	}

	#if js
	function asyncLoad(path:String, callback:js.html.XMLHttpRequest->Void, responseType=js.html.XMLHttpRequestResponseType.TEXT):js.html.XMLHttpRequest
	{
		var http = new js.html.XMLHttpRequest();
		http.responseType = responseType;
		http.onreadystatechange = function() {
			if (http.readyState == js.html.XMLHttpRequest.DONE) {
				if (http.status == 200) {
					callback(http);
				} else {
					fail();
				}
			}
		}
		http.open('GET', path, true);
		http.send();
		return http;
	}
	#end

	function loadBytes(path:String)
	{
		var aliases = assets.get(path);
#if (!lime && js)
		asyncLoad(path, function(http) {
			var bytes = haxe.io.Bytes.ofData(http.response);
			for (alias in aliases) {
				cache.addBytes(alias, bytes);
			}
			success();
		}, js.html.XMLHttpRequestResponseType.ARRAYBUFFER);
#else
		var bytes = AssetCache.assetLoader.getBytes(path);
		if (bytes == null)
		{
			Log.critical('Failed to load bytes: ${path}');
			fail();
		}
		else
		{
			for (alias in aliases) {
				cache.addBytes(alias, bytes);
			}
		}
		success();
#end
	}

	function loadText(path:String)
	{
		var aliases = assets.get(path);
#if (!lime && js)
		asyncLoad(path, function(http) {
			var text = http.responseText;
			for (alias in aliases) {
				cache.addText(alias, text);
			}
			success();
		});
#else
		var text = AssetCache.assetLoader.getText(path);
		if (text == null)
		{
			Log.critical('Failed to load text: ${path}');
			fail();
		}
		else
		{
			for (alias in aliases) {
				cache.addText(alias, text);
			}
			success();
		}
#end
	}

	function loadFont(path:String)
	{
		var aliases = assets.get(path);
		#if (!lime && js)
		var http = asyncLoad(path, function(http) {
			var name = Path.withoutDirectory(Path.withoutExtension(path));
			var font = new js.html.FontFace(name, http.response);
			font.load().then(function(face) {
				js.Browser.document.fonts.add(face);
				success();
			}).catchError(function(error) {
				Log.error('Failed to load font: $path\n$error');
				fail();
			});
		});
		http.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
		#else
		// fonts not supported on other targets
		fail();
		#end
	}

	public function load()
	{
		// TODO: allow for custom extensions
		for (path in assets.keys())
		{
			switch (Path.extension(path))
			{
				case "jpg", "jpeg", "png": loadTexture(path);
				case "mp3", "ogg", "wav":  loadSound(path);
				case "woff", "ttf":        loadFont(path);
				case "xm":                 loadBytes(path);
				default: loadText(path);
			}
		}
	}

	#end // !macro

// ------------------------------------
// MACRO SECTION

	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		#if !unit_test
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
							var outPath = Path.directory(Compiler.getOutput());
							var preloadBlocks = [for (param in meta.params) findAndCopyAssets(parseMetaPath(param), outPath)];
							// wrap the function block with the preloader code
							f.expr = macro {
								_preloader = new haxepunk.assets.Preloader();
								_preloader.onLoad.bind(function() {
									${f.expr};
								});
								$b{preloadBlocks};
								_preloader.load();
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
				access: [APrivate, AStatic],
				pos: Context.currentPos(),
				kind: FieldType.FVar(macro : haxepunk.assets.Preloader, null)
			});
		}
		#end
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
			case EObjectDecl(fields):
				var v = ExprTools.getValue(expr);
				var ext:Array<String> = cast v.ext;
				if (Type.getClass(v.ext) == String) { ext = [v.ext]; }
				{ path: v.path, alias: v.alias, extensions: ext };
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

	static function copyAsset(path, finalPath):Bool
	{
		try
		{
			// check if file exists and are the same size
			if (FileSystem.exists(finalPath) && FileSystem.stat(path).size == FileSystem.stat(finalPath).size) return true;

			Log.debug("Copy file " + path + " to " + finalPath);
			FileSystem.createDirectory(Path.directory(finalPath));
			File.copy(path, finalPath);
			return true;
		}
		catch (e:Dynamic)
		{
			Log.error("Caught exception while trying to copy " + path);
			return false;
		}
	}

	static function findAssetPath(path:String):Null<String>
	{
		// try to search the parent directories of the current file for the asset path
		var posInfos = Context.getPosInfos(Context.currentPos());
		var dir = Path.directory(Path.normalize(posInfos.file));
		while (dir.length > 0)
		{
			dir = Path.directory(dir);
			var newPath = Path.join([dir, path]);
			if (FileSystem.exists(newPath)) return newPath;
		}
		return null;
	}

	static function checkValidExtension(preloadPath:PreloadPath, path:String):Bool {
		if (preloadPath.extensions == null) return true;

		for (ext in preloadPath.extensions)
		{
			if (path.indexOf(ext) >= 0)
				return true;
		}
		return false;
	}

	static function findAndCopyAssets(preloadPath:PreloadPath, ?outPath:String):Expr {
		var search = [preloadPath.path];
		var iterations = 0;
		var exprs = [];
		while (iterations < 1000 && search.length > 0)
		{
			var originalPath = search.pop();
			var path = findAssetPath(originalPath);
			if (path != null)
			{
				if (FileSystem.isDirectory(path))
				{
					for (item in FileSystem.readDirectory(path))
					{
						// TODO: don't require the asset path to be searched for every item
						search.push(Path.join([originalPath, item]));
					}
				}
				else if (checkValidExtension(preloadPath, path))
				{
					var aliases = [];
					if (preloadPath.alias != null)
					{
						aliases.push(StringTools.replace(originalPath, preloadPath.path, preloadPath.alias));
					}

					// copy asset if outPath is defined and only add the asset if it is successfully copied, or if outPath is null
					if (outPath == null || copyAsset(path, Path.join([outPath, originalPath])))
					{
						exprs.push(macro _preloader.addAsset($v{originalPath}, $v{aliases}));
					}
				}
			}
			iterations += 1;
		}

		if (exprs.length == 0)
		{
			Log.warning('No assets found for path ${preloadPath.path}');
		}

		return macro $b{exprs};
	}
	#end
}
