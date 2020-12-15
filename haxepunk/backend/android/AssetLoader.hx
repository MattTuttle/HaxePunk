package haxepunk.backend.android;

import java.NativeArray;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import haxe.io.Bytes;
import haxepunk.utils.Color;
import haxepunk.audio.Sound;
import haxepunk.backend.generic.render.Texture as BaseTexture;
import haxepunk.backend.android.Texture;

@:native("android.content.res.AssetManager")
extern class AssetManager
{
    public function open(filename:String):InputStream;
}

@:native("android.graphics.BitmapFactory")
extern class BitmapFactory
{
	public static function decodeFile(pathName:String):Bitmap;
	public static function decodeStream(pathName:InputStream):Bitmap;
}

/**
 * AssetLoader is used to load a new copy of an asset, bypassing the cache.
 */
class AssetLoader implements haxepunk.assets.AssetLoader
{
    public static var assets:AssetManager;

    public function new() {}

	public function createTexture(width:Int, height:Int, transparent:Bool=false, color:Color=0):BaseTexture
    {
        var bitmap = Bitmap.createBitmap(width, height, BitmapConfig.ARGB_8888);
        bitmap.eraseColor(color.toARGB(1));
        return new Texture(bitmap);
    }

    function open(id:String):InputStream return assets.open(StringTools.replace(id, "assets/", ""));

    function readBytes(id:String):ByteArrayOutputStream
    {
        var stream = open(id);
        var result = new ByteArrayOutputStream();
        var buffer = new NativeArray<java.types.Int8>(1024);
        while (true)
        {
            var length = stream.read(buffer);
            if (length == -1)
            {
                return result;
            }
            result.write(buffer, 0, length);
        }
    }

	public function getText(id:String):Null<String>
    {
        return readBytes(id).toString("UTF-8");
    }

	public function getBytes(id:String):Null<Bytes>
    {
        return Bytes.ofData(readBytes(id).toByteArray());
    }

	public function getSound(id:String):Sound
    {
        return null;
    }

	public function getTexture(id:String):Null<BaseTexture>
    {
        return new Texture(BitmapFactory.decodeStream(open(id)));
    }
}
