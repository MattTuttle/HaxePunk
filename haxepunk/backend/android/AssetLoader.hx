package haxepunk.backend.android;

import haxe.io.Bytes;
import haxepunk.utils.Color;
import haxepunk.audio.Sound;
import haxepunk.backend.generic.render.Texture as BaseTexture;
import haxepunk.backend.android.Texture;


/**
 * AssetLoader is used to load a new copy of an asset, bypassing the cache.
 */
class AssetLoader implements haxepunk.assets.AssetLoader
{
    public function new() {}

	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):BaseTexture
    {
        var bitmap = Bitmap.createBitmap(width, height, BitmapConfig.ARGB_8888);
        bitmap.eraseColor(color.toARGB(1));
        return new Texture(bitmap);
    }

	public function getText(id:String):Null<String>
    {
        return null;
    }

	public function getBytes(id:String):Null<Bytes>
    {
        return null;
    }

	public function getSound(id:String):Sound
    {
        return null;
    }

	public function getTexture(id:String):Null<BaseTexture>
    {
        return new Texture(Bitmap.createBitmap(10, 10, BitmapConfig.ARGB_8888));
    }
}
