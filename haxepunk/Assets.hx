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
                var buffer = lime.Assets.getImage(id).buffer;
    			texture.loadFromBytes(buffer.data.toBytes(), Std.int(buffer.width), buffer.bitsPerPixel);
    		}
    		else
    		{
    			trace('No texture named $id');
    		}
#end
        }
		return texture;
    }
}
