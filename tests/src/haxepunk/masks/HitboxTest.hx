package haxepunk.masks;

import massive.munit.Assert;
import haxepunk.Entity;
import haxepunk.Mask;
import haxepunk.masks.Hitbox;
import haxepunk.masks.Circle;
import haxepunk.math.Projection;
import haxepunk.math.Vector2;

class HitboxTest extends TestSuite
{
	var box:Hitbox;

	@Before
	public function setup()
	{
		box = new Hitbox(20, 20, -10, -10);
	}

	@Test
	public function testCollideMask()
	{
		var mask = new Mask();
		Assert.isTrue(box.collide(mask));
		Assert.isFalse(mask.collide(box));
	}

	@Test
	public function testCollideHitbox()
	{
		var hitbox = new Hitbox(50, 50);
		Assert.isTrue(hitbox.collide(box));
	}

	@Test
	public function testCircle()
	{
		function collideCircle(radius:Int, x:Int, y:Int):Bool
		{
			return (new Circle(radius, x, y)).collide(box);
		}

		// hit
		Assert.isTrue(collideCircle(8, 0, 0));

		// miss
		Assert.isFalse(collideCircle(8, 20, 0));
		Assert.isFalse(collideCircle(8, 0, 20));
	}

	@Test
	public function testParentX()
	{
		box.parent = new Entity();
		box.x = 20;
		Assert.areEqual(-20, box.parent.originX);
	}

	@Test
	public function testParentY()
	{
		box.parent = new Entity();
		box.y = 13;
		Assert.areEqual(-13, box.parent.originY);
	}

	@Test
	public function testParentWidth()
	{
		box.parent = new Entity();
		box.width = 52;
		Assert.areEqual(52, box.parent.width);
	}

	@Test
	public function testParentHeight()
	{
		box.parent = new Entity();
		box.height = 68;
		Assert.areEqual(68, box.parent.height);
	}

	@Test
    public function testProject()
    {
        function testProjection(x, y, min, max)
        {
            var projection = new Projection();
            box.project(new Vector2(x, y), projection);
            Assert.areEqual(min, projection.min);
            Assert.areEqual(max, projection.max);
        }

        box = new Hitbox(40, 24);
        testProjection(5, 3, 0, 272);
        testProjection(79, -24, -576, 3160);
		box = new Hitbox(40, 24, -5, 0);
        testProjection(5, 3, -25, 247);
        box = new Hitbox(40, 24, -5, 24);
        testProjection(5, 3, 47, 319);
        box = new Hitbox(-32, 24, -5, 24);
        testProjection(5, 3, -113, 119);
        box = new Hitbox(-32, -15, -5, 24);
        testProjection(5, 3, -158, 47);
    }
}
