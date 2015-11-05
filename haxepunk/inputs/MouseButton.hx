package haxepunk.inputs;

/**
 * The mouse buttons.
 * To be used with Input.define, Input.check, Input.pressed, Input.released and Mouse.nameOf.
 *
 * Warning: ANY also encompass buttons that aren't listed here, for mouse with more than 3 buttons.
 */
@:enum abstract MouseButton(Int) to Int
{
	var ANY = -1;
	var LEFT = 0;
	var MIDDLE = 1;
	var RIGHT = 2;

	@:op(A<B) private inline function less (rhs:Int):Bool { return this < rhs; }
	@:op(A>B) private inline function more (rhs:Int):Bool { return this > rhs; }
}
