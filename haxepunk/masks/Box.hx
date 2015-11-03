package haxepunk.masks;

import haxepunk.math.*;

class Box extends Rectangle implements Mask
{

	/**
	 * Constructor.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	x			X position of the hitbox.
	 * @param	y			Y position of the hitbox.
	 */
	public function new(width:Float=0, height:Float=0, x:Float=0, y:Float=0)
	{
		super(x, y, width, height);
	}

	public var min(get, never):Vector3;
	private inline function get_min():Vector3 { return new Vector3(left, top); }

	public var max(get, never):Vector3;
	private inline function get_max():Vector3 { return new Vector3(right, bottom); }

	public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
		haxepunk.graphics.Draw.rect(offset.x + x, offset.y + y, width, height, color);
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
