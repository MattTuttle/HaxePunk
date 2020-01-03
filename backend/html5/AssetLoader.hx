package backend.html5;

import haxe.ds.StringMap;
import haxepunk.utils.Log;
import haxepunk.utils.Color;
import haxepunk.Sfx;
import backend.generic.render.Texture;

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
		trace("getSound Unimplemented");
		return null;
	}

	public function getTexture(id:String):Null<Texture>
	{
		trace(id);
		trace("getTexture Unimplemented");
		return null;
	}

	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		trace("createTexture Unimplemented");
		return null;
	}

	public function addShortcut(path:String, pointsTo:String):Void
	{
		shortcuts.set(path, pointsTo);
	}

	var shortcuts = new StringMap<String>();
}
