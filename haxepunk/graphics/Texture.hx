package haxepunk.graphics;

import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxepunk.renderers.Renderer;
import haxepunk.math.Math;

class Texture
{

	/**
	 * The width of the texture in memory
	 */
	public var width(default, null):Int = 0;

	/**
	 * The height of the texture in memory
	 */
	public var height(default, null):Int = 0;

	/**
	 * Set to true if texture should be filtered smooth
	 */
	public var smooth:Bool = false;

	/**
	 * Number of color bits per pixel
	 * RGBA = 32 bits (8 red, 8 green, 8 blue, 8 alpha)
	 * RGB = 24 bits (8 red, 8 green, 8 alpha)
	 * Alpha = 8 bits (8 alpha)
	 */
	public var bitsPerPixel(default, null):Int = 0;

	public var data(default, null):Bytes;

	public var id(default, null):String;


	public static function fromSize(width:Int, height:Int, bitsPerPixel:Int=32):Texture
	{
		var texture = new Texture();
		texture.width = width;
		texture.height = height;
		texture.bitsPerPixel = bitsPerPixel;
		return texture;
	}

	/**
	 * Create a texture from RGBA data.
	 * @param data the RGBA texture data. Must be 4 Int values per pixel.
	 * @param stride the byte width of the texture.
	 */
	public static function fromRGBA(data:Array<Int>, stride:Int):Texture
	{
		var texture = new Texture();
		var bytes = Bytes.alloc(data.length);
		for (i in 0...data.length) bytes.set(i, data[i]);
		texture.loadFromBytes(bytes, stride);
		return texture;
	}

	/**
	 * Creates texture from XPM data. http://en.wikipedia.org/wiki/X_PixMap
	 * @param xpm a string of xpm data
	 */
	public static function fromXPM(xpm:String):Texture
	{
		var lines = xpm.split("\n");
		if ("! XPM" != lines.shift()) return null;

		var format = lines.shift().split(" ");
		var width = Std.parseInt(format[0]);
		var height = Std.parseInt(format[1]);
		var numColors = Std.parseInt(format[2]);
		var charPerPixel = Std.parseInt(format[3]);

		var bytes = Bytes.alloc(width * height * 4);
		var colors = new StringMap<Int>();

		for (i in 0...numColors)
		{
			var fields = lines.shift().split(" ");
			var color = 0, c = 0;
			var colorStr = fields[2];
			for (i in 0...colorStr.length)
			{
				var code = StringTools.fastCodeAt(colorStr, i);
				if (code >= '0'.code && code <= '9'.code)
				{
					c = (code - '0'.code);
				}
				else if (code >= 'A'.code && code <= 'F'.code)
				{
					c = (code - 'A'.code + 10);
				}
				else
				{
					continue;
				}
				color |= c << ((colorStr.length - i - 1) * 4);
			}
			// add alpha
			colors.set(fields[0], color);
		}

		for (y in 0...lines.length)
		{
			if (y >= height) break;
			var line = lines[y];
			for (x in 0...Std.int(line.length / charPerPixel))
			{
				if (x >= width) break;
				var colorId = "";
				for (i in 0...charPerPixel)
				{
					colorId += line.charAt(x * charPerPixel + i);
				}
				if (colors.exists(colorId))
				{
					var color = colors.get(colorId);
					var byteOffset = (y * width + x) * 4;
					bytes.set(byteOffset, color >> 16 & 0xFF);
					bytes.set(byteOffset+1, color >> 8 & 0xFF);
					bytes.set(byteOffset+2, color & 0xFF);
					bytes.set(byteOffset+3, 0xFF);
				}
				else
				{
					throw 'Unknown color "$colorId" in XPM data';
				}
			}
		}

		var texture = new Texture();
		texture.loadFromBytes(bytes, width);
		return texture;
	}

	@:allow(haxepunk.graphics)
	private function new(?id:String)
	{
		this.id = (id == null) ? Math.uuid() : id;
		// TODO: throw warning if duplicate id found?
		_textures.set(this.id, this);
	}

	/**
	 * Get a texture from the pool or create a new one
	 */
	public static function get(id:String):Texture
	{
		return Texture._textures.exists(id) ? Texture._textures.get(id) : new Texture(id);
	}

	/**
	 * Load from RGBA bytes
	 * @param bytes   The bytes to load into Texture.
	 * @param stride  The width in bytes
	 */
	public function loadFromBytes(bytes:Bytes, stride:Int, bitsPerPixel:Int=32)
	{
		var bytesPerPixel = bitsPerPixel / 8,
			pixels = Std.int(bytes.length / bytesPerPixel);
		this.width = stride;
		this.height = Std.int(pixels / stride);
		this.bitsPerPixel = bitsPerPixel;
		this.data = bytes;
#if flash
		// flash requires BGRA instead of RGBA
		if (bitsPerPixel == 32)
		{
			for (i in 0...pixels)
			{
				var tmp = bytes.get(i * 4);
				bytes.set(i * 4, bytes.get(i * 4 + 2));
				bytes.set(i * 4 + 2, tmp);
			}
		}
#end
	}

	/**
	 * Binds the texture for drawing
	 * @param sampler the id of the sampler to use
	 */
	public inline function bind(renderer:Renderer, sampler:Int=0):Void
	{
		renderer.bindTexture(this, sampler);
	}

	private static var _textures = new StringMap<Texture>();

}
