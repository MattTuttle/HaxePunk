package haxepunk;

import massive.munit.Assert;
import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.Scene;

class ScreenTest extends TestSuite
{
	@Before
	public function setup()
	{
		HXP.windowWidth = 320;
		HXP.windowHeight = 480;
		HXP.engine = new Engine(HXP.windowWidth, HXP.windowHeight);
		HXP.screen.scaleMode.setBaseSize();
	}

	@Test
	public function testSetXY()
	{
		var screen = new Screen();
		screen.x = 50;
		screen.y = 75;
		Assert.areEqual(50, screen.x);
		Assert.areEqual(75, screen.y);
	}

	@Test
	public function testDefaultSize()
	{
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(1.0, HXP.screen.scale);
	}
}
