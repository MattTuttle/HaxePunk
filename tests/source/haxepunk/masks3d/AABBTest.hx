package haxepunk.masks3d;

import haxepunk.math.Vector3;

class AABBTest extends haxe.unit.TestCase
{

	public function testZero()
	{
		var a = new AABB();
		var b = new AABB();
		assertEquals(null, a.overlapAABB(b));
	}

	public function testOverlap()
	{
		var a = new AABB(new Vector3(-1, -1, -1), new Vector3(1, 1, 1));
		var b = new AABB(new Vector3(-1, -1, -1), new Vector3(2, 2, 2));
		assertTrue(new Vector3(-2, -2, -2) == a.overlapAABB(b));

		// touching edges does not count as collision (no penetration)
		b.min.x = b.min.y = b.min.z = 1;
		assertEquals(null, a.overlap(b));
	}

	public function testIntersection()
	{
		var a = new AABB(new Vector3(-1, -1, -1), new Vector3(1, 1, 1));
		var b = new AABB(new Vector3(-1, -1, -1), new Vector3(2, 2, 2));
		assertTrue(a.intersectsAABB(b));
		assertTrue(b.intersectsAABB(a));

		b.min.x = b.min.y = b.min.z = 1;
		assertTrue(a.intersectsAABB(b));
	}

	public function testProperties()
	{
		var aabb = new AABB(new Vector3(-1, -1, -1), new Vector3(1, 2, 3));
		assertEquals(2.0, aabb.width);
		assertEquals(3.0, aabb.height);
		assertEquals(4.0, aabb.depth);

		assertEquals(0.0, aabb.center.x);
		assertEquals(0.5, aabb.center.y);
		assertEquals(1.0, aabb.center.z);

		assertEquals(-1.0, aabb.left);
		assertEquals(-1.0, aabb.top);
		assertEquals(-1.0, aabb.front);

		assertEquals(1.0, aabb.right);
		assertEquals(2.0, aabb.bottom);
		assertEquals(3.0, aabb.back);

		assertEquals(2.0, aabb.width = aabb.height = aabb.depth = 2);
		assertEquals(1.0, aabb.max.x);
		assertEquals(1.0, aabb.max.y);
		assertEquals(1.0, aabb.max.z);

		assertEquals(0.0, aabb.right);
		assertEquals(0.0, aabb.bottom);
		assertEquals(0.0, aabb.back);
	}

}
