package haxepunk;

import massive.munit.Assert;

class CameraTest
{
	var camera:Camera;
	var screen:Screen;

	@Before
	public function setup()
	{
		camera = new Camera();
		screen = HXP.screen = new Screen(800, 600);
	}

	@Test
	public function testCameraScaleX()
	{
		Assert.areEqual(1, camera.fullScaleX);
		screen.scaleX = 1.5;
		Assert.areEqual(1.5, camera.fullScaleX);
		camera.scaleX = 2;
		Assert.areEqual(3, camera.fullScaleX);
		camera.scale = 4.5;
		Assert.areEqual(13.5, camera.fullScaleX);
	}

	@Test
	public function testCameraScaleY()
	{
		Assert.areEqual(1, camera.fullScaleY);
		screen.scaleY = 1.5;
		Assert.areEqual(1.5, camera.fullScaleY);
		camera.scaleY = 2;
		Assert.areEqual(3, camera.fullScaleY);
		camera.scale = 4.5;
		Assert.areEqual(13.5, camera.fullScaleY);
	}

	@Test
	public function testCameraWidth()
	{
		Assert.areEqual(800, camera.width);
	}
}
