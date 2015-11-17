package haxepunk.inputs;

@:access(haxepunk.inputs)
class KeyboardTest extends haxe.unit.TestCase
{

	public var input:Input;

	override public function setup()
	{
		input = new Input();
	}

	public function testKeyDown()
	{
		input.keyboard.onKeyDown(Key.LEFT, 0);
		assertTrue(input.check(Key.LEFT));
	}

	public function testKeyUp()
	{
		for (key in Key.A...Key.Z)
		{
			var k:Key = cast key;
			input.keyboard.onKeyUp(k, 0);
			assertEquals(1, input.released(k));
		}
	}

	public function testDefine()
	{
		input.define("jump", [Key.SPACE, Key.UP]);
		input.keyboard.onKeyDown(Key.SPACE, 0);
		assertTrue(input.check("jump"));
	}

}
