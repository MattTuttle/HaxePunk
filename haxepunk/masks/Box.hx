package haxepunk.masks;

import haxepunk.math.*;

class Box implements Mask
{

	public var origin:Vector3;
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
	public var min(default, null):Vector3;
	public var max(default, null):Vector3;

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
		this.origin = new Vector3(x, y);
		this.min = new Vector3();
		this.max = new Vector3();
		this.width = width;
		this.height = height;
	}

	public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
		haxepunk.graphics.Draw.rect(offset.x + origin.x + min.x, offset.y + origin.y + min.y, width, height, color);
	}

	public function overlap(other:Mask):Vector3
	{
		if (Std.is(other, Box)) return overlapBox(cast other);
		if (Std.is(other, Circle)) return cast(other, Circle).overlapBox(this);
		return null;
	}

	/** @private Collides against an Entity. */
	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, Box)) return intersectsBox(cast other);
		if (Std.is(other, Circle)) return cast(other, Circle).intersectsBox(this);
		return false;
	}

	public function intersectsBox(other:Box):Bool
	{
		return right >= other.left && left <= other.right &&
			bottom >= other.top && top <= other.bottom;
	}

	public function containsPoint(point:Vector3):Bool
	{
		return point.x >= left && point.x <= right && point.y >= top && point.y <= bottom;
	}

	public function overlapBox(other:Box):Vector3
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

}
