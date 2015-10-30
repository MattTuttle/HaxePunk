package haxepunk.masks;

import haxepunk.math.Vector3;
import haxepunk.scene.Entity;
import haxepunk.graphics.Color;

interface Mask
{

	/**
	 * Checks if two masks intersect.
	 * @return True if the two masks intersect.
	 */
	public function intersects(other:Mask):Bool;

	/**
	 * Get the separation vector if two masks overlap.
	 * @return A separation vector that can be used to separate the two masks.
	 */
	public function overlap(other:Mask):Vector3;

	/**
	 * Check if a point exists within a mask.
	 * @param point The point to check.
	 * @return True if the point is contained within the mask.
	 */
	public function containsPoint(point:Vector3):Bool;

	/**
	 * Draws the mask to the screen.
	 * @param offset An offset to position the mask.
	 * @param color The color to draw the mask outline.
	 */
	public function debugDraw(offset:Vector3, color:Color):Void;

}
