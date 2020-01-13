package haxepunk.assets;

import haxepunk.utils.Color;
import haxepunk.backend.generic.Sound;
import haxepunk.backend.generic.render.Texture;

/**
 * AssetLoader is used to load a new copy of an asset, bypassing the cache.
 */
interface AssetLoader
{
	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture;

	public function getText(id:String):Null<String>;

	public function getSound(id:String):Sound;

	public function getTexture(id:String):Null<Texture>;
}
