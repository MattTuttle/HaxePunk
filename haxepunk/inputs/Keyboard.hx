package haxepunk.inputs;

import haxe.ds.IntMap;
import haxepunk.inputs.Input;
import haxepunk.inputs.InputState;
import lime.ui.Window;
import lime.ui.KeyCode;

/**
 * Get information on the keyboard input.
 */
class Keyboard
{

	/** Contains the string of the last keys pressed */
	public var buffer(default, null):String = "";

	/** Holds the last key detected */
	public var last(default, null):Key = Key.ANY;

	/**
	 * Returns the name of the key.
	 *
	 * @param key The key to name
	 * @return The name of [key]
	 */
	public function nameOf(key:Key):String
	{
		var char:Int = cast key;
		//~ trace(char, Key.NUMPAD_0, Key.NUMPAD_9);

		if (char == -1)
		{
			return "";
		}
		if (char >= Std.int(Key.A) && char <= Std.int(Key.Z))
		{
			return String.fromCharCode(char - Std.int(Key.A) + 65);
		}
		if (char >= Std.int(Key.F1) && char <= Std.int(Key.F12))
		{
			return "F" + Std.string(char - Std.int(Key.F1) + 1);
		}
		if (char >= Std.int(Key.NUMPAD_1) && char <= Std.int(Key.NUMPAD_0))
		{
			return "NUMPAD " + Std.string((char - Std.int(Key.NUMPAD_1) + 1)%10);
		}
		if (char >= Std.int(Key.DIGIT_0) && char <= Std.int(Key.DIGIT_9))
		{
			return Std.string(char - Std.int(Key.DIGIT_0));
		}

		return switch (key)
		{
			case LEFT: "LEFT";
			case UP: "UP";
			case RIGHT: "RIGHT";
			case DOWN: "DOWN";

			case LEFT_SQUARE_BRACKET: "[";
			case RIGHT_SQUARE_BRACKET: "]";
			//~ case TILDE: "~";

			case ENTER: "ENTER";
			case SPACE: "SPACE";
			case BACKSPACE: "BACKSPACE";
			case DELETE: "DELETE";
			case END: "END";
			case ESCAPE: "ESCAPE";
			case HOME: "HOME";
			case INSERT: "INSERT";
			case TAB: "TAB";
			case PAGE_DOWN: "PAGE DOWN";
			case PAGE_UP: "PAGE UP";

			case NUMPAD_ADD: "NUMPAD ADD";
			case NUMPAD_DECIMAL: "NUMPAD DECIMAL";
			case NUMPAD_DIVIDE: "NUMPAD DIVIDE";
			case NUMPAD_ENTER: "NUMPAD ENTER";
			case NUMPAD_MULTIPLY: "NUMPAD MULTIPLY";
			case NUMPAD_SUBTRACT: "NUMPAD SUBTRACT";

			default: "KEY " + char; // maybe something better?
		}
	}



	/**
	 * Setup the keyboard input support.
	 */
	@:allow(haxepunk.inputs.Input)
	private function new(window:Window):Void
	{
		// Register the events from lime
		window.onKeyDown.add(onKeyDown);
		window.onKeyUp.add(onKeyUp);
		// window.onTextInput.add(onTextInput);
	}

	/**
	 * Return the value for a key.
	 *
	 * @param key The key to check
	 * @param v The value to get
	 * @return The value of [v] for [key]
	 */
	@:allow(haxepunk.inputs.Input)
	private function value(key:Key, v:InputValue):Int
	{
		if (Std.int(key) <= -1) // Any
		{
			var result = 0;
			for (state in _states)
			{
				result += state.value(v);
			}
			return result;
		}
		else
		{
			return getInputState(cast key).value(v);
		}
	}

	/**
	 * Updates the keyboard state.
	 */
	@:allow(haxepunk.inputs.Input)
	private function update():Void
	{
		// Was On last frame if was on the previous one and there is at least the same amount of Pressed than Released.
		// Or wasn't On last frame and Pressed > 0
		for (state in _states)
		{
			state.on = ( (state.on > 0 && state.pressed >= state.released) || (state.on == 0 && state.pressed > 0) ) ? 1 : 0;
			state.pressed = 0;
			state.released = 0;
		}
	}

	/**
	 * Lime onKeyDown event.
	 */
	private function onKeyDown(keycode:Int, modifiers:Int):Void
	{
		getInputState(keycode).pressed += 1;
		last = cast keycode;
		switch (keycode)
		{
			case Key.ENTER:
				buffer += "\n";
			case Key.BACKSPACE:
				buffer = buffer.substr(0, -1);
		}
	}

	/**
	 * Lime onKeyUp event.
	 */
	private function onKeyUp(keycode:Int, modifiers:Int):Void
	{
		getInputState(keycode).released += 1;
		last = cast keycode;
	}

	/**
	 * Lime onTextInput event.
	 */
	private function onTextInput(text:String):Void
	{
		buffer += text;
	}

	/**
	 * Gets a mouse state object from a button number.
	 */
	private function getInputState(button:Int):InputState
	{
		var state:InputState;
		if (_states.exists(button))
		{
			state = _states.get(button);
		}
		else
		{
			state = new InputState();
			_states.set(button, state);
		}
		return state;
	}

	private var _states:IntMap<InputState> = new IntMap<InputState>();

}


@:enum
abstract Modifer(Int) to Int
{
	var LEFT_SHIFT  = 0x0001;
	var RIGHT_SHIFT = 0x0002;
	var SHIFT       = 0x0003;
	var LEFT_CTRL   = 0x0040;
	var RIGHT_CTRL  = 0x0080;
	var CTRL        = 0x00C0;
	var LEFT_ALT    = 0x0100;
	var RIGHT_ALT   = 0x0200;
	var ALT         = 0x0300;
	var LEFT_META   = 0x0400;
	var RIGHT_META  = 0x0800;
	var META        = 0x0C00;
	var NUM_LOCK    = 0x1000;
	var CAPS_LOCK   = 0x2000;
	var MODE        = 0x4000;
}
