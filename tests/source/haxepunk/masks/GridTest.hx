package haxepunk.masks;

import haxepunk.math.*;

class GridTest extends haxe.unit.TestCase
{

	public function testBoxIntersection()
	{
		var g = new Grid(10, 10);
		var b = new Box();
		assertFalse(g.intersects(b));
	}

}
