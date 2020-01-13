package haxepunk.backend.flash.assets;

import flash.display.BitmapData;
import haxepunk.utils.Color;
import haxepunk.backend.flash.graphics.hardware.Texture;

import flash.Assets;
// FIXME: add abstract for sound assets
import flash.media.Sound;

class AssetLoader implements haxepunk.assets.AssetLoader
{
	public function new() {}

	public function getText(id:String):String
	{
		return Assets.getText(id);
	}

	public function getSound(id:String):Sound
	{
		return Assets.getSound(id, false);
	}

	public function getTexture(id:String):Texture
	{
		return new Texture(Assets.getBitmapData(id, false));
	}

	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		return new Texture(new BitmapData(width, height, transparent, color));
	}
}
