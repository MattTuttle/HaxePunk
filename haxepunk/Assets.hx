package haxepunk;

import haxepunk.graphics.Texture;

class Assets
{
    public static function getText(id:String):String
    {
#if lime
        return lime.Assets.getText(id);
#end
    }

    public static function exists(id:String):Bool
    {
#if lime
        return lime.Assets.exists(id);
#end
    }

    /**
     * Get a texture from an asset
     * @param id the asset id to find
     */
    public static function getTexture(id:String):Texture
    {
		var texture = Texture.get(id);
        if (texture.width == 0 && texture.height == 0)
        {
#if lime
    		if (Assets.exists(id))
    		{
                var image = lime.Assets.getImage(id);
                var buffer = image.buffer;
#if flash
                var bounds = new flash.geom.Rectangle(0, 0, buffer.width, buffer.height);
                var bytes = haxe.io.Bytes.ofData(cast(image.src, flash.display.BitmapData).getPixels(bounds));
#else
                var bytes = buffer.data.toBytes();
#end
    			texture.loadFromBytes(bytes, Std.int(buffer.width), buffer.bitsPerPixel);
    		}
    		else
    		{
    			Log.log('No texture named $id');
    		}
#end
        }
		return texture;
    }
}
