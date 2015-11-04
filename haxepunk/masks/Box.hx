package haxepunk.masks;

import haxepunk.math.*;

class Box extends Mask
{

	public var width(default, set):Float;
	public function set_width(value:Float):Float
	{
		max.x = value / 2;
		min.x = -max.x;
		return width = value;
	}
	public var height(default, set):Float;
	public function set_height(value:Float):Float
	{
		max.y = value / 2;
		min.y = -max.y;
		return height = value;
	}

	public var halfWidth(get, never):Float;
	private inline function get_halfWidth():Float { return max.x; }
	public var halfHeight(get, never):Float;
	private inline function get_halfHeight():Float { return max.y; }

	public var left(get, never):Float;
	private inline function get_left():Float { return origin.x + min.x; }
	public var right(get, never):Float;
	private inline function get_right():Float { return origin.x + max.x; }
	public var top(get, never):Float;
	private inline function get_top():Float { return origin.y + min.y; }
	public var bottom(get, never):Float;
	private inline function get_bottom():Float { return origin.y + max.y; }

	/**
	 * Constructor.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	x			X position of the hitbox.
	 * @param	y			Y position of the hitbox.
	 */
	public function new(width:Float=0, height:Float=0, x:Float=0, y:Float=0)
	{
		super(x, y);
		this.width = width;
		this.height = height;

		register(Box, intersectsBox, separateBox);
	}

	override public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
		haxepunk.graphics.Draw.rect(offset.x + left, offset.y + top, width, height, color);
	}

	override public function containsPoint(point:Vector3):Bool
	{
		return point.x >= left && point.x <= right && point.y >= top && point.y <= bottom;
	}

	public function intersectsBox(other:Box):Bool
	{
		return right >= other.left && left <= other.right &&
			bottom >= other.top && top <= other.bottom;
	}

	public function separateBox(other:Box):Vector3
	{
		var left = other.left - this.right;
		var right = other.right - this.left;
		var top = other.top - this.bottom;
		var bottom = other.bottom - this.top;

		if (left >= 0 || right <= 0 || top >= 0 || bottom <= 0)
		{
			return null;
		}

		return new Vector3(
			(Math.abs(left) < right) ? left : right,
			(Math.abs(top) < bottom) ? top : bottom,
			0
		);
	}

	override public function project(axis:Vector3):Projection
	{
		// dot product of top left corner
		var min = left * axis.x + top * axis.y,
			max = min;

		// dot product of top right corner
		var result = right * axis.x + top * axis.y;
		if (result < min) min = result;
		if (result > max) max = result;

		// dot product of bottom left corner
		result = left * axis.x + bottom * axis.y;
		if (result < min) min = result;
		if (result > max) max = result;

		// dot product of bottom right corner
		result = right * axis.x + bottom * axis.y;
		if (result < min) min = result;
		if (result > max) max = result;

		return new Projection(min, max);
	}

}
