package haxepunk.inputs;

/**
 * The mouse buttons.
 * To be used with Input.define, Input.check, Input.pressed, Input.released and Mouse.nameOf.
 *
 * Warning: ANY also encompass buttons that aren't listed here, for mouse with more than 3 buttons.
 */
@:enum abstract MouseButton(Int) to Int from Int
{
	var ANY = -1;
	var LEFT = 0;
	var MIDDLE = 1;
	var RIGHT = 2;

	public inline function toString():String {
		return switch (this) {
			case ANY: "";
			case LEFT: "LEFT";
			case MIDDLE: "MIDDLE";
			case RIGHT: "RIGHT";
			default: return "MOUSE (" + this + ")";
		}
	}
}
