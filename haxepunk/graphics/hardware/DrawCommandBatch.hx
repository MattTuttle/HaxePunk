package haxepunk.graphics.hardware;

import haxepunk.graphics.shader.Shader;
import haxepunk.backend.generic.render.Texture;
import haxepunk.utils.BlendMode;
import haxepunk.utils.Color;
import haxepunk.math.MathUtil;
import haxepunk.math.Rectangle;

@:dox(hide)
class DrawCommandIterator
{
	@:allow(haxepunk.graphics.hardware.DrawCommandBatch)
	var start:DrawCommand = null;
	var current:DrawCommand = null;

	public function new() {}

	public function reset()
	{
		current = start;
	}

	public function hasNext():Bool
	{
		return current != null;
	}

	public function next():DrawCommand
	{
		var result = current;
		current = current._next;
		return result;
	}

	public function recycle()
	{
		if (start != null) start.recycle();
		start = current = null;
	}
}

@:dox(hide)
class DrawCommandBatch
{
	public static var maxTriangleChecks:Int = 128;

	static var _bounds:Rectangle = new Rectangle();


	var commandList = new DrawCommandIterator();
	var last:DrawCommand;

	public function new() {}

	public inline function recycle()
	{
		commandList.recycle();
		last = null;
	}

	/**
	 * Allows DrawCommandBatch to be used in a for loop.
	 */
	public function iterator():DrawCommandIterator
	{
		commandList.reset();
		return commandList;
	}

	public function getDrawCommand(texture:Texture, shader:Shader, smooth:Bool, blend:BlendMode, clipRect:Rectangle, x1:Float=0, y1:Float=0, x2:Float=0, y2:Float=0, x3:Float=0, y3:Float=0, flexibleLayer:Bool=false)
	{
		if (last != null && last.match(texture, shader, smooth, blend, clipRect))
		{
			// we can reuse the most recent draw call
			return last;
		}

		while (last != null && last.empty())
		{
			// recycle draw commands we didn't actually populate
			var l = last;
			last = last._prev;
			if (last != null) last._next = null;
			l.recycle();
		}

		var command = DrawCommand.reuseOrCreate(texture, shader, smooth, blend, clipRect);
		if (last == null)
		{
			commandList.start = last = command;
			command._prev = null;
		}
		else
		{
			last._next = command;
			command._prev = last;
			last = command;
		}
		return command;
	}

	// faster than using color.alpha
	inline function isVisible(color:Color)
	{
		return (color & 0xFF000000) != 0;
	}

	public inline function addRect(
		texture:Texture, shader:Shader,
		smooth:Bool, blend:BlendMode, clipRect:Rectangle,
		rx:Float, ry:Float, rw:Float, rh:Float,
		a:Float, b:Float, c:Float, d:Float,
		tx:Float, ty:Float,
		color:Color, flexibleLayer:Bool = false):Void
	{
		if (isVisible(color))
		{
			var uvx1:Float, uvy1:Float, uvx2:Float, uvy2:Float;
			if (texture == null)
			{
				uvx1 = uvy1 = 0;
				uvx2 = rw;
				uvy2 = rh;
			}
			else
			{
				uvx1 = rx / texture.width;
				uvy1 = ry / texture.height;
				uvx2 = (rx + rw) / texture.width;
				uvy2 = (ry + rh) / texture.height;
			}

			// matrix transformations
			var xa = rw * a + tx;
			var yb = rw * b + ty;
			var xc = rh * c + tx;
			var yd = rh * d + ty;

			var command = getDrawCommand(texture, shader, smooth, blend, clipRect, tx, ty, xa, yb, xc, yd, flexibleLayer);

			command.addTriangle(
				tx, ty, uvx1, uvy1,
				xa, yb, uvx2, uvy1,
				xc, yd, uvx1, uvy2,
				color
			);

			command.addTriangle(
				xc, yd, uvx1, uvy2,
				xa, yb, uvx2, uvy1,
				xa + rh * c, yb + rh * d, uvx2, uvy2,
				color
			);
		}
	}

	public inline function addTriangle(texture:Texture, shader:Shader,
		smooth:Bool, blend:BlendMode, clipRect:Rectangle,
		tx1:Float, ty1:Float, uvx1:Float, uvy1:Float,
		tx2:Float, ty2:Float, uvx2:Float, uvy2:Float,
		tx3:Float, ty3:Float, uvx3:Float, uvy3:Float,
		color:Color, flexibleLayer:Bool = false):Void
	{
		if (isVisible(color))
		{
			var command = getDrawCommand(texture, shader, smooth, blend, clipRect, tx1, ty1, tx2, ty2, tx3, ty3, flexibleLayer);
			command.addTriangle(tx1, ty1, uvx1, uvy1, tx2, ty2, uvx2, uvy2, tx3, ty3, uvx3, uvy3, color);
		}
	}
}
