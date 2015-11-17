package haxepunk.inputs;

/**
 * The gamepad buttons.
 * To be used with Input.define, Input.check, Input.pressed, Input.released and Gamepad.nameOf.
 *
 * Warning: ANY also encompass buttons that aren't listed here, for gamepad with more than 10 buttons.
 */
@:enum abstract GamepadButton(Int) to Int
{
	var NONE = -2;
	var ANY = -1;

	var BUTTON0 = 0;
	var BUTTON1 = 1;
	var BUTTON2 = 2;
	var BUTTON3 = 3;
	var BUTTON4 = 4;
	var BUTTON5 = 5;
	var BUTTON6 = 6;
	var BUTTON7 = 7;
	var BUTTON8 = 8;
	var BUTTON9 = 9;

	@:op(A<B) private inline function less (rhs:Int):Bool { return this < rhs; }
	@:op(A>B) private inline function more (rhs:Int):Bool { return this > rhs; }
}
