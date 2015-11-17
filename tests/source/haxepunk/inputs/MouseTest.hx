package haxepunk.inputs;

class MouseTest extends haxe.unit.TestCase
{

	public var input:Input;

	override public function setup()
	{
		input = new Input();
		// reset mouse values
		for (state in input.mouse._states)
		{
			state.on = state.pressed = state.released = 0;
		}
	}

	public function testNameOf()
	{
		assertEquals("", Mouse.nameOf(MouseButton.ANY));
		assertEquals("LEFT", Mouse.nameOf(MouseButton.LEFT));
		assertEquals("MIDDLE", Mouse.nameOf(MouseButton.MIDDLE));
		assertEquals("RIGHT", Mouse.nameOf(MouseButton.RIGHT));
		assertEquals("MOUSE (4)", Mouse.nameOf(4));
	}

	public function testCheck()
	{
		input.define("left", [MouseButton.LEFT]);
		input.define("right", [MouseButton.RIGHT]);
		input.define("all", [MouseButton.ANY]);
		input.define("both", [MouseButton.LEFT, MouseButton.RIGHT]);

		assertFalse(input.check("left"));
		assertFalse(input.check("right"));

		// undefined but should return false instead of throwing an error
		assertFalse(input.check("foo"));

		input.mouse.onMouseDown(0, 0, MouseButton.LEFT);
		assertTrue(input.check("left"));
		assertTrue(input.check("all"));

		input.mouse.onMouseDown(0, 0, MouseButton.RIGHT);
		assertTrue(input.check("right"));
		assertTrue(input.check("all"));
		assertTrue(input.check("both"));

		input.update();

		input.mouse.onMouseUp(0, 0, MouseButton.LEFT);

		assertTrue(input.check("left")); // left is still "on" but not "pressed"

		input.update();

		assertFalse(input.check("left"));
		assertTrue(input.check("all"));
	}

	public function testMousePressed()
	{
		assertEquals(0, input.pressed(MouseButton.LEFT));

		input.mouse.onMouseDown(0, 0, MouseButton.LEFT);
		assertEquals(1, input.pressed(MouseButton.LEFT));

		input.mouse.onMouseDown(0, 0, MouseButton.LEFT);
		assertEquals(0, input.released(MouseButton.LEFT));
		assertEquals(2, input.pressed(MouseButton.LEFT));

		input.mouse.onMouseUp(0, 0, MouseButton.LEFT);
		assertEquals(1, input.released(MouseButton.LEFT));

		input.update();
		assertEquals(0, input.pressed(MouseButton.LEFT));
	}

	public function testMousePosition()
	{
		input.mouse.onMouseDown(10, 45, MouseButton.LEFT);
		assertEquals(10.0, input.mouse.x);
		assertEquals(45.0, input.mouse.y);
	}

	public function testMouseWheel()
	{
		input.mouse.onMouseWheel(1, 2);
		assertEquals(1.0, input.mouse.wheelDeltaX);
		assertEquals(2.0, input.mouse.wheelDeltaY);
	}

}
