package haxepunk.masks;

import haxepunk.math.Vector3;
import haxepunk.scene.Entity;
import haxepunk.graphics.Color;

class Mask
{

	public var origin:Vector3;

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
	}

	/**
	 * Checks if two masks intersect.
	 * @return True if the two masks intersect.
	 */
 	public function intersects(other:Mask):Bool
 	{
 		if (Std.is(other, Circle)) return intersectsCircle(cast other);
 		if (Std.is(other, Box)) return intersectsBox(cast other);
 		if (Std.is(other, Polygon)) return intersectsPolygon(cast other);
 		return false;
 	}

	// stubs for intersection checks
	public function intersectsCircle(other:Circle):Bool { throw "Not implemented"; }
	public function intersectsBox(other:Box):Bool { throw "Not implemented"; }
	public function intersectsPolygon(other:Polygon):Bool { throw "Not implemented"; }

	/**
	 * Get the separation vector if two masks overlap.
	 * @return A separation vector that can be used to separate the two masks.
	 */
	public function overlap(other:Mask):Vector3
  	{
  		if (Std.is(other, Circle)) return overlapCircle(cast other);
  		if (Std.is(other, Box)) return overlapBox(cast other);
  		if (Std.is(other, Polygon)) return overlapPolygon(cast other);
  		return null;
  	}

	// stubs for overlap checks
	public function overlapCircle(other:Circle):Vector3 { throw "Not implemented"; }
	public function overlapBox(other:Box):Vector3 { throw "Not implemented"; }
	public function overlapPolygon(other:Polygon):Vector3 { throw "Not implemented"; }

	/**
	 * Check if a point exists within a mask.
	 * @param point The point to check.
	 * @return True if the point is contained within the mask.
	 */
	public function containsPoint(point:Vector3):Bool { return false; }

	/**
	 * Draws the mask to the screen.
	 * @param offset An offset to position the mask.
	 * @param color The color to draw the mask outline.
	 */
	public function debugDraw(offset:Vector3, color:Color):Void { throw "Not implemented"; }

}
