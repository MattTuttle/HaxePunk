package haxepunk.backend.html5;

import haxe.io.Bytes;
import haxepunk.backend.html5.Texture;
import haxepunk.utils.Color;

class AssetLoader implements haxepunk.assets.AssetLoader
{
	public function new() {}

	public function getText(id:String):String
	{
		#if asset_debug
		throw "Text needs to be preloaded before calling getText for " + id;
		#else
		return "";
		#end
	}

	public function getSound(id:String):Null<Sound>
	{
		#if asset_debug
		throw "Sound needs to be preloaded before calling getSound for " + id;
		#else
		return null;
		#end
	}

	public function getTexture(id:String):Null<Texture>
	{
		#if asset_debug
		throw "Texture needs to be preloaded before calling getTexture for " + id;
		#else
		return new Texture(null, 0, 0);
		#end
	}

	public function getBytes(id:String):Null<Bytes>
	{
		#if asset_debug
		throw "Bytes needs to be preloaded before calling getBytes for " + id;
		#else
		return null;
		#end
	}

	@:access(haxepunk.backend.html5.Texture)
	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		var canvas = Texture.canvas;
		canvas.width = width;
		canvas.height = height;
		var ctx = canvas.getContext2d();
		ctx.fillStyle = "rgba(" + color.r + ", " + color.g + ", " + color.b + ", " + (transparent ? "1" : "0") + ")";
		ctx.rect(0, 0, width, height);
		ctx.fill();
		var texture = new Texture(ctx.getImageData(0, 0, width, height), width, height);
		texture.dirty = true;
		return texture;
	}
}
