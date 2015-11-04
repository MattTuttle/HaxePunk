package haxepunk.masks;

import haxepunk.math.*;

class CircleTest extends haxe.unit.TestCase
{

	public function testZero()
	{
		var a = new Circle();
		var b = new Circle();
		assertTrue(a.intersectsCircle(b));
	}

	public function testPointIntersection()
	{
		var a = new Circle(36.3, 15, 26);
		assertTrue(a.containsPoint(new Vector3(2, 4)));
		assertTrue(a.containsPoint(new Vector3(25, 25)));
		assertFalse(a.containsPoint(new Vector3(51.3, 62.3)));
		assertFalse(a.containsPoint(new Vector3(-50, -100))); // way out of bounds
		assertFalse(a.containsPoint(new Vector3(400, 299)));
	}

	public function testCircleIntersection()
	{
		var a = new Circle(30);
		var b = new Circle(20, 15, 15);

		assertTrue(a.intersectsCircle(b));
		assertTrue(b.intersectsCircle(a));

		a.origin.x = -35; a.origin.y = 15;
		assertTrue(a.intersects(b));
		a.origin.x = -30; a.origin.y = -20;
		assertFalse(a.intersectsCircle(b));
	}

	public function testCircleSeparation()
	{
		var a = new Circle(45);
		var b = new Circle(24, 50);
		var r = a.separate(b);
		assertEquals(19.0, r.x);
		assertEquals(0.0, r.y);

		b.origin.y = 24;
		var r = a.separate(b);
		assertEquals(12.205, Math.roundTo(r.x, 3));
		assertEquals(5.858, Math.roundTo(r.y, 3));

		// no separation
		a.origin.x = 150;
		a.origin.y = 150;
		var r = a.separate(b);
		assertEquals(null, r);
	}

	public function testBoxIntersection()
	{
		var b = new Box(20, 30);
		var c = new Circle(20);
		b.x = 10; b.y = 0;
		assertTrue(c.intersects(b));
		b.x = 0; b.y = 10;
		assertTrue(c.intersects(b));
		b.x = 25; b.y = 30;
		assertFalse(c.intersects(b));
		b.x = -25; b.y = -30;
		assertFalse(c.intersects(b));
	}

}
