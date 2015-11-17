package haxepunk.inputs;

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

	public function testNameOf()
	{
		assertEquals("", Keyboard.nameOf(Key.ANY));
		assertEquals("A", Keyboard.nameOf(Key.A));
		assertEquals("J", Keyboard.nameOf(Key.J));
		assertEquals("Q", Keyboard.nameOf(Key.Q));
		assertEquals("UP", Keyboard.nameOf(Key.UP));
		assertEquals("BACKSPACE", Keyboard.nameOf(Key.BACKSPACE));
		assertEquals("F4", Keyboard.nameOf(Key.F4));
		assertEquals("F12", Keyboard.nameOf(Key.F12));
		assertEquals("[", Keyboard.nameOf(Key.LEFT_SQUARE_BRACKET));
		assertEquals("NUMPAD 0", Keyboard.nameOf(Key.NUMPAD_0));
		assertEquals("NUMPAD 6", Keyboard.nameOf(Key.NUMPAD_6));
		assertEquals("2", Keyboard.nameOf(Key.DIGIT_2));
		assertEquals("7", Keyboard.nameOf(Key.DIGIT_7));
		assertEquals("KEY (1564)", Keyboard.nameOf(1564));
	}

}
