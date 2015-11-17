package haxepunk.inputs;

@:enum abstract GamepadButton(Int) to Int from Int
{
	var ANY = -1;

	// Generic button names
	var A = 0;
	var B = 1;
	var X = 2;
	var Y = 3;
	var BACK = 4;
	var HOME = 5;
	var START = 6;
	var STICK_LEFT = 7;
	var STICK_RIGHT = 8;
	var SHOULDER_LEFT = 9;
	var SHOULDER_RIGHT = 10;
	var DPAD_UP = 11;
	var DPAD_DOWN = 12;
	var DPAD_LEFT = 13;
	var DPAD_RIGHT = 14;

	public inline function toString():String {
		return switch (this) {
			case ANY: "";
			case A: "A";
			case B: "B";
			case X: "X";
			case Y: "Y";
			case BACK: "BACK";
			case HOME: "HOME";
			case START: "START";
			case STICK_LEFT: "STICK_LEFT";
			case STICK_RIGHT: "STICK_RIGHT";
			case SHOULDER_LEFT: "SHOULDER_LEFT";
			case SHOULDER_RIGHT: "SHOULDER_RIGHT";
			case DPAD_UP: "DPAD_UP";
			case DPAD_DOWN: "DPAD_DOWN";
			case DPAD_LEFT: "DPAD_LEFT";
			case DPAD_RIGHT: "DPAD_RIGHT";
			default: "GAMEPAD (" + this + ")";
		}
	}
}
