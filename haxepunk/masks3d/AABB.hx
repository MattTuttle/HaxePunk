package haxepunk.masks3d;

import haxepunk.masks.Mask;
import haxepunk.math.Vector3;

class AABB implements Mask
{

	public var origin:Vector3;

	/**
	 * Minimum point of the AABB
	 */
	public var min:Vector3;

	/**
	 * Maximum point of the AABB
	 */
	public var max:Vector3;

	/**
	 * Width of the AABB
	 */
	public var width:Float;

	/**
	 * Height of the AABB
	 */
	public var height:Float;
	/**
	 * Depth of the AABB
	 */
	public var depth:Float;

	/**
	 * The leftmost position of the AABB.
	 */
	public var left(get, never):Float;
	private inline function get_left():Float { return origin.x + min.x; }

	/**
	 * The rightmost position of the AABB.
	 */
	public var right(get, never):Float;
	private inline function get_right():Float { return origin.x + max.x; }

	/**
	 * The topmost position of the AABB.
	 */
	public var top(get, never):Float;
	private inline function get_top():Float { return origin.y + min.y; }

	/**
	 * The bottommost position of the AABB.
	 */
	public var bottom(get, never):Float;
	private inline function get_bottom():Float { return origin.y + max.y; }

	/**
	 * The frontmost position of the AABB.
	 */
	public var front(get, never):Float;
	private inline function get_front():Float { return origin.z + min.z; }

	/**
	 * The backmost position of the AABB.
	 */
	public var back(get, never):Float;
	private inline function get_back():Float { return origin.z + max.z; }

	/**
	 * The center position of the AABB. (WARNING: recalculates value every time this is used)
	 */
	public var center(get, never):Vector3;
	private function get_center():Vector3
	{
		_center.x = width * 0.5 + min.x;
		_center.y = height * 0.5 + min.y;
		_center.z = depth * 0.5 + min.z;
		return _center;
	}

	public function new(?min:Vector3, ?max:Vector3)
	{
		this.min = (min == null ? new Vector3() : min);
		this.max = (max == null ? new Vector3() : max);
		_center = new Vector3();
	}

	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, AABB)) return intersectsAABB(cast other);
		return false;
	}

	public function overlap(other:Mask):Vector3
	{
		if (Std.is(other, AABB)) return overlapAABB(cast other);
		return null;
	}

	public function containsPoint(vec:Vector3):Bool
	{
		return vec.x >= min.x && vec.x <= max.x &&
			vec.y >= min.y && vec.y <= max.y &&
			vec.z >= min.z && vec.z <= max.z;
	}

	public function intersectsAABB(other:AABB):Bool
	{
		return max.x >= other.min.x && min.x <= other.max.x &&
			max.y >= other.min.y && min.y <= other.max.y &&
			max.z >= other.min.z && min.z <= other.max.z;
	}

	public function overlapAABB(other:AABB):Vector3
	{
		var result = new Vector3();

		var left = other.min.x - max.x;
		var right = other.max.x - min.x;
		var top = other.min.y - max.y;
		var bottom = other.max.y - min.y;
		var front = other.min.z - max.z;
		var back = other.max.z - min.z;

		if (left >= 0 || right <= 0 || top >= 0 || bottom <= 0 || front >= 0 || back <= 0)
		{
			return null;
		}

		result.x = (Math.abs(left) < right) ? left : right;
		result.y = (Math.abs(top) < bottom) ? top : bottom;
		result.z = (Math.abs(front) < back) ? front : back;

		return result;
	}

	public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
		haxepunk.graphics.Draw.rect(offset.x + left, offset.y + top, width, height, color);
	}

	private var _center:Vector3;

}
