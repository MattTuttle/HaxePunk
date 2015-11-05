package haxepunk.inputs;

/**
 * The keyboard keys.
 */
@:enum
abstract Key(Int) to Int
{
	var ANY = -1;

	var LEFT = 0x40000050;
	var UP = 0x40000052;
	var RIGHT = 0x4000004F;
	var DOWN = 0x40000051;

	var ENTER = 0x0D;
	//~ var COMMAND = cast KeyCode.COMMAND;
	var SPACE = 0x20;
	var BACKSPACE = 0x08;
	var DELETE = 0x7F;
	var END = 0x4000004D;
	var ESCAPE = 0x1B;
	var HOME = 0x4000004A;
	var INSERT = 0x40000049;
	var TAB = 0x09;
	var PAGE_DOWN = 0x4000004E;
	var PAGE_UP = 0x4000004B;
	var LEFT_SQUARE_BRACKET = 0x5B;
	var RIGHT_SQUARE_BRACKET = 0x5D;
	//~ var TILDE = 192;

	var A = 0x61;
	var B = 0x62;
	var C = 0x63;
	var D = 0x64;
	var E = 0x65;
	var F = 0x66;
	var G = 0x67;
	var H = 0x68;
	var I = 0x69;
	var J = 0x6A;
	var K = 0x6B;
	var L = 0x6C;
	var M = 0x6D;
	var N = 0x6E;
	var O = 0x6F;
	var P = 0x70;
	var Q = 0x71;
	var R = 0x72;
	var S = 0x73;
	var T = 0x74;
	var U = 0x75;
	var V = 0x76;
	var W = 0x77;
	var X = 0x78;
	var Y = 0x79;
	var Z = 0x7A;

	var F1 = 0x4000003A;
	var F2 = 0x4000003B;
	var F3 = 0x4000003C;
	var F4 = 0x4000003D;
	var F5 = 0x4000003E;
	var F6 = 0x4000003F;
	var F7 = 0x40000040;
	var F8 = 0x40000041;
	var F9 = 0x40000042;
	var F10 = 0x40000043;
	var F11 = 0x40000044;
	var F12 = 0x40000045;

	var DIGIT_0 = 0x30;
	var DIGIT_1 = 0x31;
	var DIGIT_2 = 0x32;
	var DIGIT_3 = 0x33;
	var DIGIT_4 = 0x34;
	var DIGIT_5 = 0x35;
	var DIGIT_6 = 0x36;
	var DIGIT_7 = 0x37;
	var DIGIT_8 = 0x38;
	var DIGIT_9 = 0x39;

	var NUMPAD_0 = 0x40000062;
	var NUMPAD_1 = 0x40000059;
	var NUMPAD_2 = 0x4000005A;
	var NUMPAD_3 = 0x4000005B;
	var NUMPAD_4 = 0x4000005C;
	var NUMPAD_5 = 0x4000005D;
	var NUMPAD_6 = 0x4000005E;
	var NUMPAD_7 = 0x4000005F;
	var NUMPAD_8 = 0x40000060;
	var NUMPAD_9 = 0x40000061;
	var NUMPAD_ADD = 0x40000057;
	var NUMPAD_DECIMAL = 0x40000063;
	var NUMPAD_DIVIDE = 0x40000054;
	var NUMPAD_ENTER = 0x40000058;
	var NUMPAD_MULTIPLY = 0x40000055;
	var NUMPAD_SUBTRACT = 0x40000056;

}
