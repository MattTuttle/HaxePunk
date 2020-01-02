package backend.hl;

import sys.FileSystem;
import sys.io.File;
import haxepunk.utils.Log;
import haxepunk.utils.Color;
import haxepunk.assets.AssetLoader;

class FileAssetLoader implements AssetLoader
{
	public function new() {}

	function verifyFileExists(path:String):Bool
	{
		if (FileSystem.exists(path)) return true;

		Log.critical('Invalid asset path $path');
		return false;
	}

	public function getText(id:String):String
	{
		if (verifyFileExists(id))
		{
			return File.getContent(id);
		}
		return null;
	}

	public function getSound(id:String):Dynamic
	{
		if (verifyFileExists(id))
		{
			throw "Sound asset loading is unimplemented";
		}
		return null;
	}

	public function getTexture(id:String):Texture
	{
		if (verifyFileExists(id))
		{
			return Texture.loadFromBytes(File.getBytes(id));
		}
		return null;
	}

	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		var bytes = new hl.Bytes(width * height * 4);
		bytes.fill(0, width * height * 4, transparent ? 0 : color); // set default color
		return new Texture(bytes, width, height);
	}
}
