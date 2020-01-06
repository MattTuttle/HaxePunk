package backend.html5;

import backend.html5.Texture;
import haxe.ds.StringMap;
import haxepunk.Sfx;
import haxepunk.utils.Color;

class AssetLoader implements haxepunk.assets.AssetLoader
{
	public function new() {}

	public function getText(id:String):String
	{
		trace("getText Unimplemented");
		return "";
	}

	public function getSound(id:String):Null<Sfx>
	{
		throw "Sound needs to be preloaded before calling getSound for " + id;
	}

	public function getTexture(id:String):Texture
	{
		throw "Texture needs to be preloaded before calling getTexture for " + id;
	}

	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		return new Texture(width, height);
	}

	public function addShortcut(path:String, pointsTo:String):Void
	{
		shortcuts.set(path, pointsTo);
	}

	var shortcuts = new StringMap<String>();
}
