class TestMain
{

	public static function main()
	{
		var runner = new haxe.unit.TestRunner();
		haxepunk.Log.output = false;

		// graphic tests
		runner.add(new haxepunk.graphics.ColorTest());
		runner.add(new haxepunk.graphics.TilemapTest());

		// scene tests
		runner.add(new haxepunk.scene.EntityTest());
		runner.add(new haxepunk.scene.SceneTest());

		// math tests
		runner.add(new haxepunk.math.MathTest());
		runner.add(new haxepunk.math.Matrix4Test());
		runner.add(new haxepunk.math.RectangleTest());
		runner.add(new haxepunk.math.Vector3Test());

		// input tests
		runner.add(new haxepunk.inputs.InputTest());
		runner.add(new haxepunk.inputs.KeyboardTest());
		runner.add(new haxepunk.inputs.MouseTest());
		runner.add(new haxepunk.inputs.GamepadTest());

		// mask tests
		runner.add(new haxepunk.masks.BoxTest());
		runner.add(new haxepunk.masks.CircleTest());
		runner.add(new haxepunk.masks.GridTest());
		runner.add(new haxepunk.masks.PolygonTest());

		// utils tests
		runner.add(new haxepunk.utils.RandomTest());
		runner.add(new haxepunk.utils.DataStorageTest());
		runner.add(new haxepunk.utils.ArrayUtilsTest());

		runner.run();
	}

}
