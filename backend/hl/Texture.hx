package backend.hl;

import backend.opengl.GLUtils;
import haxepunk.utils.Color;
import hl.Format;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import sdl.GL;

class Texture implements backend.generic.render.Texture
{
	static final pixelFormat = PixelFormat.BGRA;

	public var width(default, null):Int;
	public var height(default, null):Int;

	final data:hl.Bytes;
	var texture:sdl.GL.Texture;
	var dirty = false;

	public function new(data:hl.Bytes, width:Int, height:Int)
	{
		this.data = data;
		this.width = width;
		this.height = height;

		if (data != null)
		{
			dirty = true;
			texture = GL.createTexture();
		}
	}

	public static function loadFromBytes(bytes:Bytes):Null<Texture>
	{
		// read first two bytes in little-endian and compare to common image headers
		return switch (bytes.getUInt16(0))
		{
			case 0xD8FF: decodeJPEG(bytes);
			case 0x5089: decodePNG(bytes);
			case 0x4947: decodeGIF(bytes);
			default: throw "Unsupported texture format";
		}
	}

	static function decodeGIF(bytes:Bytes):Null<Texture>
	{
		var original = hl.Bytes.fromBytes(bytes);
		var width = bytes.getUInt16(6);
		var height = bytes.getUInt16(8);
		throw "GIF format not supported";
		return new Texture(original, width, height);
	}

	static function decodePNG(bytes:Bytes):Null<Texture>
	{
		var input = new BytesInput(bytes);
		var original = hl.Bytes.fromBytes(bytes);
		var width = 0;
		var height = 0;

		input.bigEndian = true;
		input.position = 8; // skip header

		while (true)
		{
			var chunkLength = input.readInt32();
			if (input.readString(4) == "IHDR")
			{
				width = input.readInt32();
				height = input.readInt32();
				break;
			}
			if (chunkLength == 0) return null;
			input.position += chunkLength + 4; // jump past crc and chunk data
		}

		var stride = width * 4;
		var data = new hl.Bytes(stride * height);
		if (width > 0 && height > 0 && Format.decodePNG(original, input.length, data, width, height, stride, pixelFormat, 0))
		{
			return new Texture(data, width, height);
		}
		return null;
	}

	static function decodeJPEG(bytes:Bytes):Null<Texture>
	{
		var input = new BytesInput(bytes);
		var original = hl.Bytes.fromBytes(bytes);
		var width = 0;
		var height = 0;

		input.bigEndian = true;
		input.position = 2;
		while (true)
		{
			var data = input.readUInt16();
			var length = input.readUInt16();
			switch (data)
			{
				case 0xFFC2, 0xFFC1, 0xFFC0:
					input.readByte();
					height = input.readUInt16();
					width = input.readUInt16();
					trace(width, height);
					break;
				default:
					input.position += length - 2;
			}
		}
		var stride = width * 4;
		var data = new hl.Bytes(stride * height);
		if (width > 0 && height > 0 && Format.decodeJPG(original, input.length, data, width, height, stride, pixelFormat, 0))
		{
			return new Texture(data, width, height);
		}
		return null;
	}

	public function bind()
	{
		GL.bindTexture(GL.TEXTURE_2D, texture);

		// check if the texture has changed and need to be uploaded to the gpu
		if (dirty)
		{
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.BGRA, GL.UNSIGNED_BYTE, data);

			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.NEAREST);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}

		GLUtils.checkForErrors();
	}

	inline function getByteIndex(x:Int, y:Int):Int
	{
		return y * width * 4 + x * 4;
	}

	public function getPixel(x:Int, y:Int):Color
	{
		return Color.fromBGRA(data.getI32(getByteIndex(x, y)));
	}

	public function setPixel(x:Int, y:Int, c:Color):Void
	{
		dirty = true;
		data.setI32(getByteIndex(x, y), c.toBGRA());
	}

	public function removeColor(color:Color):Void
	{
		throw "Texture removeColor is unimplemented";
	}

	public function drawCircle(x:Float, y:Float, radius:Float):Void
	{
		var x1 = Std.int(Math.max(0, x - radius));
		var x2 = Std.int(Math.min(width, x + radius));
		var y1 = Std.int(Math.max(0, y - radius));
		var y2 = Std.int(Math.min(height, y + radius));
		var radiusSquared = radius * radius;
		for (py in y1...y2)
		{
			var dy = py - y;
			for (px in x1...x2)
			{
				var dx = px - x;
				if (dx * dx + dy * dy < radiusSquared)
				{
					setPixel(px, py, 0xFFFFFF);
				}
			}
		}
	}

	public function dispose():Void
	{
		GL.deleteTexture(texture);
		texture = null;
	}
}
