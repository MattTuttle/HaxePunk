package haxepunk.inputs;

@:access(haxepunk.inputs.Keyboard)
class KeyboardTest extends haxe.unit.TestCase
{

	public function testKeyDown()
	{
		Keyboard.onKeyDown(Key.LEFT, 0);
		assertTrue(Input.check(Key.LEFT));
	}

	public function testKeyUp()
	{
		for (key in Key.A...Key.Z)
		{
			var k:Key = cast key;
			Keyboard.onKeyUp(k, 0);
			assertEquals(1, Input.released(k));
		}
	}

	public function testDefine()
	{
		Input.define("jump", [Key.SPACE, Key.UP]);
		Keyboard.onKeyDown(Key.SPACE, 0);
		assertTrue(Input.check("jump"));
	}

}
