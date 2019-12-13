package haxepunk.assets;

import haxepunk.utils.Color;
import backend.generic.render.Texture;

/**
 * AssetLoader is used to load a new copy of an asset, bypassing the cache.
 */
interface AssetLoader
{
	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture;

	public function getText(id:String):String;

	public function getSound(id:String):Dynamic;

	public function getTexture(id:String):Texture;
}
