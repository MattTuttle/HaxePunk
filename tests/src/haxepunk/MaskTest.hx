package haxepunk;

import massive.munit.Assert;
import haxepunk.masks.Masklist;
import haxepunk.math.Projection;
import haxepunk.math.Vector2;

class MaskTest
{
    var mask:Mask;

    @Before
    public function setup()
    {
        mask = new Mask();
    }

    @Test
    public function testParent()
    {
        Assert.isNull(mask.parent);
        mask.parent = new Entity();
        Assert.isNotNull(mask.parent);
    }

    @Test
    public function testCollide()
    {
        Assert.isFalse(mask.collide(mask));
        mask.parent = new Entity(20, 20);
        var m = new Mask();
        m.parent = new Entity(50, 20);
        Assert.isFalse(mask.collide(m));
        Assert.isFalse(m.collide(mask));

        mask.parent.setHitbox(50, 50);
        m.parent.setHitbox(50, 50);
        Assert.isTrue(m.collide(mask));
    }

    @Test
    public function testCollideEmptyMasklist()
    {
        var m = new Masklist();
        Assert.isFalse(mask.collide(m));
    }

    @Test
    public function testProject()
    {
        function testProjection(x, y, min, max)
        {
            var projection = new Projection();
            mask.project(new Vector2(x, y), projection);
            Assert.areEqual(min, projection.min);
            Assert.areEqual(max, projection.max);
        }

        mask.parent = new Entity(20, 10);
        mask.parent.setHitbox(40, 24);
        testProjection(5, 3, 0, 272);
        testProjection(79, -24, -576, 3160);
        mask.parent.originX = 5;
        testProjection(5, 3, -25, 247);
        mask.parent.originY = -24;
        testProjection(5, 3, 47, 319);
        mask.parent.width = -32;
        testProjection(5, 3, -113, 119);
        mask.parent.height = -15;
        testProjection(5, 3, -158, 47);
    }

    @Test
    public function testDrawContext()
    {
        Assert.isNotNull(Mask.drawContext);
    }
}
