package haxepunk.backend.linc;

import haxe.io.BytesData;
import haxepunk.graphics.hardware.ImageData;
import haxepunk.utils.Color;
import stb.Image;

class BytesImageData implements ImageData
{
	public var width(default, null):Int;
	public var height(default, null):Int;

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
		var bd = new BytesImageData(width, height, transparent ? 4 : 3, new BytesData());
		bd.clearColor(color);
		return bd;
	}

	public static inline function get(name:String):Null<BytesImageData>
	{
#if linc_stb
		var info = stb.Image.load(name);
		if (info == null) return null;
		return new BytesImageData(info.w, info.h, info.comp, info.bytes);
#else
		return null;
#end
	}

	public inline function getPixel(x:Int, y:Int):Int
	{
		return data[(y * width + x) * components];
	}

	public inline function removeColor(color:Color)
	{
		throw "Unimplemented";
	}

	public function clearColor(color:Color)
	{
		// TODO: change to something faster (memset?)
		for (i in 0...(height * width))
		{
			data[i] = color;
		}
	}

	public function drawCircle(x:Float, y:Float, radius:Float)
	{
		throw "Unimplemented";
	}

	public inline function dispose():Void
	{
		width = height = 0;
		data = null;
	}
}
