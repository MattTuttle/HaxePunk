package backend.hl;

import backend.opengl.GLUtils;
import haxepunk.utils.Color;
import hl.Format;
import haxe.io.Bytes;
import sdl.GL;

enum ImageFormat
{
	Jpeg;
	Png;
	Gif;
	Tga;
	Unknown;
}

class Texture implements backend.generic.render.Texture
{
	public var width:Int = 0;
	public var height:Int = 0;

	var pixelFormat = PixelFormat.BGRA;
	var data:hl.Bytes;
	var format:ImageFormat = Unknown;
	var texture:sdl.GL.Texture;
	var dirty = false;

	public function new(bytes:Bytes)
	{
		// read first two bytes and compare to common image headers
		switch (bytes.getUInt16(0))
		{
			case 0xD8FF: decodeJPEG(bytes);
			case 0x5089: decodePNG(bytes);
			case 0x4947: decodeGIF(bytes);
			default: throw "Unsupported texture format";
		}
		if (data != null)
		{
			dirty = true;
			texture = GL.createTexture();
			trace(StringTools.hex(getPixel(0, 0)));
		}
	}

	inline function getInt32BigEndian(bytes:Bytes, pos:Int):Int
	{
		return bytes.get(pos) << 24 | bytes.get(pos+1) << 16 | bytes.get(pos+2) << 8 | bytes.get(pos+3);
	}

	inline function getUInt16BigEndian(bytes:Bytes, pos:Int):UInt
	{
		return bytes.get(pos) << 8 | bytes.get(pos+1);
	}

	function decodeGIF(bytes:Bytes)
	{
		format = Gif;
		width = bytes.getUInt16(6);
		height = bytes.getUInt16(8);
		throw "GIF format not supported";
	}

	function decodePNG(bytes:Bytes):Bool
	{
		format = Png;
		var offset = 8;
		while (offset < bytes.length)
		{
			var dataLen = getInt32BigEndian(bytes, offset);
			if (bytes.getString(offset+4, 4) == "IHDR")
			{
				width = getInt32BigEndian(bytes, offset + 8);
				height = getInt32BigEndian(bytes, offset + 12);
				break;
			}
			offset += dataLen + 12;
		}
		var stride = width * 4;
		data = new hl.Bytes(stride * height);
		return Format.decodePNG(hl.Bytes.fromBytes(bytes), bytes.length, data, width, height, stride, pixelFormat, 0);
	}

	function decodeJPEG(bytes:Bytes):Bool
	{
		format = Jpeg;
		var offset = 2;
		while (offset < bytes.length)
		{
			var data = getUInt16BigEndian(bytes, offset);
			switch (data)
			{
				case 0xFFC2, 0xFFC1, 0xFFC0:
					height = getUInt16BigEndian(bytes, offset + 5);
					width = getUInt16BigEndian(bytes, offset + 7);
					break;
				default:
					offset += 2;
					offset += getUInt16BigEndian(bytes, offset);
			}
		}
		var stride = width * 4;
		data = new hl.Bytes(stride * height);
		return Format.decodeJPG(hl.Bytes.fromBytes(bytes), bytes.length, data, width, height, stride, pixelFormat, 0);
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
		throw "Texture drawCircle is unimplemented";
	}

	public function dispose():Void
	{

	}
}
