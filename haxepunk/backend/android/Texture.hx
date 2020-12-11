package haxepunk.backend.android;

import haxepunk.utils.Color;

@:native("android.graphics.Bitmap$Config")
extern class BitmapConfig {
	public static var ARGB_8888:BitmapConfig;
	public static var RGB_565:BitmapConfig;
}

@:native("android.graphics.Bitmap")
extern class Bitmap
{
	public static function createBitmap(width:Int, height:Int, config:BitmapConfig):Bitmap;
	public function getPixel(x:Int, y:Int):Int;
	public function setPixel(x:Int, y:Int, color:Int):Void;
	public function eraseColor(color:Int):Void;
	public function getWidth():Int;
	public function getHeight():Int;
}

@:native("android.opengl.GLUtils")
extern class GLUtils
{
	public static function texImage2D(target:Int, level:Int, internalformat:Int, bitmap:Bitmap, border:Int):Void;
}

class Texture implements haxepunk.backend.generic.render.Texture
{
	public var width(default, null):Int;
	public var height(default, null):Int;
	var texture:Int;
    var bitmap:Bitmap;
    var dirty:Bool = false;

    public function new(bitmap:Bitmap)
    {
		this.bitmap = bitmap;
        this.width = bitmap.getWidth();
        this.height = bitmap.getHeight();

        texture = GL.createTexture();
        dirty = true;
    }

	public function getPixel(x:Int, y:Int):Color { return bitmap.getPixel(x, y); }
	public function setPixel(x:Int, y:Int, c:Color):Void { bitmap.setPixel(x, y, c); }

	// for removing background from bitmap fonts
	public function removeColor(color:Color):Void { throw "unimplemented"; }
	// used in Image.createCircle
	public function drawCircle(x:Float, y:Float, radius:Float):Void { throw "unimplemented"; }

	public function bind():Void
	{
		GL.bindTexture(GL.TEXTURE_2D, texture);

		// check if the texture has changed and need to be uploaded to the gpu
		if (dirty)
		{
			GLUtils.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, bitmap, 0);

			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.NEAREST);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			dirty = false;
		}
    }

	public function dispose():Void
    {
        GL.deleteTexture(texture);
        texture = -1;
    }
}
