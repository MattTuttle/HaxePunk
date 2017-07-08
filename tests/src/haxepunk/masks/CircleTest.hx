package haxepunk.masks;

import massive.munit.Assert;
import haxepunk.Entity;
import haxepunk.Mask;
import haxepunk.masks.Circle;

class CircleTest
{
	@Before
	public function setup()
	{
		circle = new Circle(30, -15, -15);
	}

	@Test
	public function testCollideMask()
	{
		var m = new Mask();
		Assert.isTrue(circle.collide(m));

		m.parent = new Entity(20, 20);
		m.parent.setHitbox(40, 40);
		Assert.isTrue(circle.collide(m));

		circle.x = 85;
		circle.y = 85;
		Assert.isFalse(circle.collide(m));
	}

	@Test
	public function testCollideCircle()
	{
		var c = new Circle(20, -10, -10);
		Assert.isTrue(circle.collide(c));

		c.x = 60;
		Assert.isTrue(circle.collide(c));
		c.y = 70;
		Assert.isFalse(circle.collide(c));
	}

	var circle:Circle;
}
