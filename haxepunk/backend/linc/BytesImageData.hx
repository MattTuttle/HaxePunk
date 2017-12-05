package haxepunk.backend.linc;

import haxe.io.Bytes;
import haxe.io.BytesData;
import haxepunk.graphics.hardware.ImageData;
import haxepunk.utils.Color;
import haxepunk.math.MathUtil;

class BytesImageData implements ImageData
{
	public var width:Int;
	public var height:Int;

	public var data(default, null):BytesData;

	public var components(default, null):Int;

	function new(width:Int, height:Int, components:Int, data:BytesData)
	{
		this.width = width;
		this.height = height;
		this.data = data;
		this.components = components;
	}

	public static inline function create(width:Int, height:Int, transparent:Bool, color:Color):BytesImageData
	{
		var components = transparent ? 4 : 3;
		var bytes = Bytes.alloc(width*height*components);
		var bd = new BytesImageData(width, height, components, bytes.getData());
		bd.clearColor(color);
		return bd;
	}

	public static inline function get(name:String):Null<BytesImageData>
	{
#if linc_stb
		var bytes = HXP.app.assets.getBytes(name);
		if (bytes == null) return null;
		var info = stb.Image.load_from_memory(bytes.getData(), bytes.length);
		if (info == null) return null;
		// premultiply alpha
		if (info.comp == 4)
		{
			for (i in 0...(info.w * info.h))
			{
				var index = i * 4;
				var alpha = 0xFF / info.bytes[index+3];
				info.bytes[index] = Std.int(info.bytes[index] * alpha);
				info.bytes[index+1] = Std.int(info.bytes[index+1] * alpha);
				info.bytes[index+2] = Std.int(info.bytes[index+2] * alpha);
			}
		}
		return new BytesImageData(info.w, info.h, info.comp, info.bytes);
#else
		return null;
#end
	}

	public inline function getPixel(x:Int, y:Int):Int
	{
		return data[(y * width + x) * components];
	}

	public inline function setPixel(x:Int, y:Int, color:Color):Void
	{
		var index = (y * width + x) * components;

		data[index] = color.r;
		data[index+1] = color.g;
		data[index+2] = color.b;

		if (components == 4)
		{
			data[index+3] = color.a;
		}
	}

	public inline function removeColor(color:Color)
	{
		var transparent:Color = 0x00000000;
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				if (getPixel(x, y) == color)
				{
					setPixel(x, y, transparent);
				}
			}
		}
	}

	/**
	 * Clears the texture to a specific color. This is not fast since it loops through every pixel of the texture.
	 */
	public function clearColor(color:Color)
	{
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				setPixel(x, y, color);
			}
		}
	}

	public function drawCircle(x:Int, y:Int, radius:Int)
	{
		var offsetX = x - radius;
		var offsetY = y - radius;
		var radiusSquared = radius*radius;
		var diameter = radius*2;

		for (ry in 0...diameter)
		{
			for (rx in 0...diameter)
			{
				if (MathUtil.distanceSquared(rx, ry, radius, radius) < radiusSquared)
				{
					setPixel(offsetX + rx, offsetY + ry, 0xFFFFFFFF);
				}
			}
		}
	}

	public inline function dispose():Void
	{
		width = height = 0;
		data = null;
	}
}
