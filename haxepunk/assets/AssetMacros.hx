package haxepunk.assets;

#if macro
import haxe.io.Path;
import sys.FileSystem;
import haxe.macro.Expr;
#end

class AssetMacros
{
	macro public static function findAsset(cache:Expr, map:Expr, other:Expr, id:Expr, addRef:Expr, fallback:Expr, ?onRef:Expr)
	{
		if (onRef == null) onRef = macro {};
		return macro {
			var result = null;
			// if we already have this asset cached, return it
			if (${map}.exists(${id}))
			{
				result = ${map}[${id}];
			}
			else
			{
				// if another active cache already has this texture cached, return
				// their version
				for (otherCache in active)
				{
					if (${other}.exists(${id}))
					{
						var cached = $other[${id}];
						if (${addRef} && cached != null)
						{
							// keep this asset cached here too, in case the owning cache is
							// disposed before this one is
							Log.debug('adding asset cache reference: ' + ${cache} + ':$id -> ' + otherCache.name + ':$id');
							${map}[${id}] = cached;
							${onRef};
						}
						result = cached;
					}
				}
				// no cached version; load from asset loader
				if (result == null) result = ${map}[${id}] = ${fallback};
			}
			result;
		}
	}

	macro public static function preload(path:String, as:String):Expr
	{
		var search = [path];
		var iterations = 0;
		while (iterations < 1000 && search.length > 0)
		{
			path = search.pop();
			trace(path);
			if (FileSystem.exists(path))
			{
				if (FileSystem.isDirectory(path))
				{
					for (item in FileSystem.readDirectory(path))
					{
						var from = Path.join([path, item]);
						// search.push(from);
					}
				}
				else
				{
					switch (Path.extension(path))
					{
						case "jpg", "jpeg", "png":
							trace("texture");
						case "mp3", "ogg", "wav":
							trace("audio");
					}
				}
			}
			iterations += 1;
		}
		return macro null;
	}
}
