package haxepunk.inputs;

import haxepunk.inputs.Gamepad;

class GamepadTest extends haxe.unit.TestCase
{

	public var input:Input;
	public var gamepad:Gamepad;

	override public function setup()
	{
		input = new Input();
		gamepad = new Gamepad("test", 0, "12345");
		input.gamepads.push(gamepad);
	}

	public function testGUID()
	{
		assertEquals("test", gamepad.name);
		assertEquals("12345", gamepad.guid);
		assertEquals(0, gamepad.id);
	}

	public function testButtonPressed()
	{
		assertEquals(0, input.pressed(GamepadButton.A));
		// "press" the button
		gamepad.onButtonDown(GamepadButton.A);
		assertTrue(input.check(GamepadButton.A));
		assertTrue(input.check(GamepadButton.ANY)); // any
		assertEquals(1, input.pressed(GamepadButton.A));
		assertEquals(GamepadButton.A, gamepad.last);
	}

	public function testButtonReleased()
	{
		assertEquals(0, input.released(GamepadButton.START));
		// "press" the button
		gamepad.onButtonUp(GamepadButton.START);
		assertFalse(input.check(GamepadButton.START));
		assertFalse(input.check(GamepadButton.ANY)); // any
		assertEquals(1, input.released(GamepadButton.START));
	}

	public function testAxis()
	{
		gamepad.onAxisMove(0, 0.5);
		assertEquals(0.5, gamepad.getAxis(0));
		gamepad.onAxisMove(3, 0.72583);
		assertEquals(0.72583, gamepad.getAxis(3));
		assertEquals(0.0, gamepad.getAxis(2));
		gamepad.onAxisMove(1099, 1.5342);
		assertEquals(1.0, gamepad.getAxis(1099));
	}

	// don't move when under deadzone
	public function testDeadZone()
	{
		gamepad.onAxisMove(0, -0.000001);
		assertEquals(0.0, gamepad.getAxis(0));

		gamepad.onAxisMove(1, 0.0000001);
		assertEquals(0.0, gamepad.getAxis(1));

		gamepad.deadZone = 0.5;
		gamepad.onAxisMove(1, -0.49);
		assertEquals(0.0, gamepad.getAxis(1));
	}

	public function testConnection()
	{
		assertTrue(gamepad.isConnected);
		gamepad.onDisconnect();
		assertFalse(gamepad.isConnected);
	}

	public function testNameOf()
	{
		assertEquals("", Gamepad.nameOf(GamepadButton.ANY));
		assertEquals("A", Gamepad.nameOf(GamepadButton.A));
		assertEquals("B", Gamepad.nameOf(GamepadButton.B));
		assertEquals("X", Gamepad.nameOf(GamepadButton.X));
		assertEquals("Y", Gamepad.nameOf(GamepadButton.Y));
		assertEquals("START", Gamepad.nameOf(GamepadButton.START));
		assertEquals("BACK", Gamepad.nameOf(GamepadButton.BACK));
		assertEquals("HOME", Gamepad.nameOf(GamepadButton.HOME));
		assertEquals("STICK_LEFT", Gamepad.nameOf(GamepadButton.STICK_LEFT));
		assertEquals("STICK_RIGHT", Gamepad.nameOf(GamepadButton.STICK_RIGHT));
		assertEquals("SHOULDER_LEFT", Gamepad.nameOf(GamepadButton.SHOULDER_LEFT));
		assertEquals("SHOULDER_RIGHT", Gamepad.nameOf(GamepadButton.SHOULDER_RIGHT));
		assertEquals("DPAD_UP", Gamepad.nameOf(GamepadButton.DPAD_UP));
		assertEquals("DPAD_DOWN", Gamepad.nameOf(GamepadButton.DPAD_DOWN));
		assertEquals("DPAD_LEFT", Gamepad.nameOf(GamepadButton.DPAD_LEFT));
		assertEquals("DPAD_RIGHT", Gamepad.nameOf(GamepadButton.DPAD_RIGHT));
		assertEquals("GAMEPAD (15)", Gamepad.nameOf(15));
	}

}
