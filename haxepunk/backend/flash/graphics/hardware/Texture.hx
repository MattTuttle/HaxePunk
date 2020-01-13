package haxepunk.backend.flash.graphics.hardware;

import haxepunk.utils.Color;

import flash.display.BitmapData;
import flash.geom.Point;

class Texture implements haxepunk.backend.generic.render.Texture
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	public function new(data:BitmapData)
	{
		this.data = data;
		width = data.width;
		height = data.height;
	}

	public inline function removeColor(color:Color)
	{
		data.threshold(data, data.rect, _zero, "==", color, 0x00000000, 0xFFFFFFFF, true);
	}

	public inline function clearColor(color:Color)
	{
		data.fillRect(data.rect, color);
	}

	public function drawCircle(x:Float, y:Float, radius:Float)
	{
		var sprite = new flash.display.Sprite();
		sprite.graphics.clear();
		sprite.graphics.beginFill(0xFFFFFF);
		sprite.graphics.drawCircle(x, y, radius);
		data.draw(sprite);
	}

	public function getPixel(x:Int, y:Int):Color
	{
		return data.getPixel(x, y);
	}

	public function setPixel(x:Int, y:Int, c:Color):Void
	{
		data.setPixel(x, y, c);
	}

	public function bind():Void
	{
		// TODO: bind this thing!
	}

	public function dispose():Void
	{
		data.dispose();
	}

	var data:BitmapData;
	static var _zero = new Point(0, 0);
}
