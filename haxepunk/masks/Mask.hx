package haxepunk.masks;

import haxe.ds.StringMap;
import haxepunk.math.*;
import haxepunk.scene.Entity;
import haxepunk.graphics.Color;

typedef IntersectionCallback = Dynamic->Bool;
typedef SeparationCallback = Dynamic->Vector3;

class Mask
{

	public var origin:Vector3;

	public var x(get, set):Float;
	private inline function get_x():Float { return origin.x; }
	private inline function set_x(value:Float):Float { return origin.x = value; }

	public var y(get, set):Float;
	private inline function get_y():Float { return origin.y; }
	private inline function set_y(value:Float):Float { return origin.y = value; }

	public var z(get, set):Float;
	private inline function get_z():Float { return origin.z; }
	private inline function set_z(value:Float):Float { return origin.z = value; }

	/**
	 * Absolute minimum point of mask (used for bounds)
	 */
	public var min(default, null):Vector3;

	/**
	 * Absolute maximum point of mask (used for bounds)
	 */
	public var max(default, null):Vector3;

	public function new(x:Float=0, y:Float=0, z:Float=0)
	{
		this.origin = new Vector3(x, y, z);
		this.min = new Vector3();
		this.max = new Vector3();

		_className = Type.getClassName(Type.getClass(this));
		_intersects = new StringMap<IntersectionCallback>();
		_separation = new StringMap<SeparationCallback>();
	}

	public function toString():String { return _className; }

	/**
	 * Checks if two masks intersect.
	 * @return True if the two masks intersect.
	 */
 	public function intersects(other:Mask):Bool
 	{
		var callback = _intersects.get(other._className);
		if (callback != null) return callback(other);

		callback = other._intersects.get(_className);
		if (callback != null) return callback(this);

		throw "Not implemented";
 	}

	/**
	 * Get the separation vector if two masks separate.
	 * @return A separation vector that can be used to separate the two masks.
	 */
	public function separate(other:Mask):Null<Vector3>
  	{
		var callback = _separation.get(other._className);
		if (callback != null) return callback(other);

		callback = other._separation.get(_className);
		if (callback != null) return callback(this);

		throw "Not implemented";
  	}

	/**
	 * @private Register callbacks for masks.
	 * @param mask        The class of mask to register.
	 * @param intersects  The intersection callback for this mask.
	 * @param separate    The separation callback for this mask.
	 */
	private function register(mask:Class<Mask>, intersects:IntersectionCallback, ?separate:SeparationCallback):Void
	{
		var name = Type.getClassName(mask);
		_intersects.set(name, intersects);
		if (separate != null)
		{
			_separation.set(name, separate);
		}
	}

	/**
	 * Check if a point exists within a mask.
	 * @param point The point to check.
	 * @return True if the point is contained within the mask.
	 */
	public function containsPoint(point:Vector3):Bool { return false; }

	/**
	 * Project the mask onto an axis
	 */
	public function project(axis:Vector3):Projection { throw "Not implemented"; }

	/**
	 * Draws the mask to the screen.
	 * @param offset An offset to position the mask.
	 * @param color The color to draw the mask outline.
	 */
	public function debugDraw(offset:Vector3, color:Color):Void { throw "Not implemented"; }

	private var _className:String;
	private var _intersects:StringMap<IntersectionCallback>;
	private var _separation:StringMap<SeparationCallback>;

}
