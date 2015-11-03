package haxepunk.masks3d;

import haxepunk.masks.Mask;
import haxepunk.math.Vector3;

class Sphere implements Mask
{

	/**
	 * Position of the Sphere.
	 */
	public var origin:Vector3;

	public var min:Vector3;
	public var max:Vector3;

	/**
	 * Radius of the Sphere.
	 */
	public var radius(default, set):Float;
	private function set_radius(value:Float):Float
	{
		min.x = min.y = min.z = -value;
		max.x = max.y = max.z = value;
		return radius = value;
	}

	public function new(?origin:Vector3, radius:Float=0)
	{
		this.origin = (origin == null ? new Vector3() : origin);
		this.min = new Vector3();
		this.max = new Vector3();
		this.radius = radius;
	}

	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, Sphere)) return intersectsSphere(cast other);
		return false;
	}

	public function overlap(other:Mask):Vector3
	{
		return null;
	}

	public function containsPoint(vec:Vector3):Bool
	{
		var dx:Float = origin.x - vec.x;
		var dy:Float = origin.y - vec.y;
		var dz:Float = origin.z - vec.z;
		return (dx * dx + dy * dy + dz * dz) <= radius * radius;
	}

	public function intersectsSphere(other:Sphere):Bool
	{
		var dx:Float = origin.x - other.origin.x;
		var dy:Float = origin.y - other.origin.y;
		var dz:Float = origin.z - other.origin.z;
		return (dx * dx + dy * dy + dz * dz) < Math.pow(radius + other.radius, 2);
	}

	public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
	}

}
