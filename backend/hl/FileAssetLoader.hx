package backend.hl;

import backend.openal.Sfx;
import haxe.ds.StringMap;
import sys.FileSystem;
import sys.io.File;
import haxepunk.assets.AssetLoader;
import haxepunk.utils.Log;
import haxepunk.utils.Color;

class FileAssetLoader implements AssetLoader
{
	public function new() {}

	function resolvePath(path:String):String
	{
		if (FileSystem.exists(path))
		{
			return path;
		}
		for (shortcut in shortcuts.keys())
		{
			if (StringTools.startsWith(path, shortcut))
			{
				var newPath = StringTools.replace(path, shortcut, shortcuts.get(shortcut));
				if (FileSystem.exists(newPath))
				{
					return newPath;
				}
			}
		}
		throw 'Invalid asset path $path';
	}

	public function getText(id:String):String
	{
		return File.getContent(resolvePath(id));
	}

	public function getSound(id:String):Sfx
	{
		return Sfx.loadFromBytes(File.getBytes(resolvePath(id)));
	}

	public function getTexture(id:String):Texture
	{
		return Texture.loadFromBytes(File.getBytes(resolvePath(id)));
	}

	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		var bytes = new hl.Bytes(width * height * 4);
		bytes.fill(0, width * height * 4, transparent ? 0 : color); // set default color
		return new Texture(bytes, width, height);
	}

	public function addShortcut(path:String, pointsTo:String):Void
	{
		shortcuts.set(path, pointsTo);
	}

	var shortcuts = new StringMap<String>();
}
