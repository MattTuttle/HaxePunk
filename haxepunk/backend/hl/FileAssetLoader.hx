package haxepunk.backend.hl;

import haxe.io.Bytes;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import haxepunk.assets.AssetLoader;
import haxepunk.utils.Color;
import haxepunk.audio.Sound;

class FileAssetLoader implements AssetLoader
{
	public function new() {}

	function resolvePath(path:String):String
	{
		// check current working directory first
		if (FileSystem.exists(path))
		{
			return path;
		}
		// then check the program path
		var programPath = Path.directory(Sys.programPath());
		var assetPath = Path.join([programPath, path]);
		if (FileSystem.exists(assetPath))
		{
			return assetPath;
		}
		throw 'Invalid asset path $path';
	}

	public function getText(id:String):String
	{
		return File.getContent(resolvePath(id));
	}

	public function getBytes(id:String):Bytes
	{
		return File.getBytes(resolvePath(id));
	}

	public function getSound(id:String):Sound
	{
		return Sound.loadFromBytes(File.getBytes(resolvePath(id)));
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
}
