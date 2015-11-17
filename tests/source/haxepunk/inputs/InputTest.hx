package haxepunk.inputs;

import haxepunk.inputs.Key;

class InputTest extends haxe.unit.TestCase
{

	public var input:Input;

	override public function setup()
	{
		input = new Input();
	}

	public function testDefine()
    {
		input.define("jump", [Key.SPACE, GamepadButton.A, MouseButton.LEFT]);
		assertEquals("jump", input._defines.keys().next());
		assertEquals(3, input._defines.get("jump").length);
    }

	public function testDefineMerge()
	{
		input.define("left", [Key.LEFT, Key.A]);
		assertEquals(2, input._defines.get("left").length);
		input.define("left", [GamepadButton.DPAD_LEFT], true);
		assertEquals(3, input._defines.get("left").length);
	}

	public function testDefineExtend()
	{
		input.define("left", [Key.LEFT, Key.A]);
		input.define("all_left", ["left", GamepadButton.DPAD_LEFT], true);
		input.keyboard.onKeyDown(Key.LEFT, Modifier.NONE);
		assertTrue(input.check(Key.LEFT));
		assertTrue(input.check("left"));
		assertTrue(input.check("all_left"));
	}

}
