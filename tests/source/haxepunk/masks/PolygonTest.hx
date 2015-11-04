package haxepunk.masks;

import haxepunk.math.Vector3;

class PolygonTest extends haxe.unit.TestCase
{

	public function testPolygonIntersection()
	{
		var a = Polygon.createRegular();
		var b = Polygon.createRegular();
		assertTrue(a.intersects(b));
	}

	public function testBoxIntersection()
	{
		var p = Polygon.createRegular();
		var b = new Box();
		assertTrue(p.intersects(b));
	}

}
