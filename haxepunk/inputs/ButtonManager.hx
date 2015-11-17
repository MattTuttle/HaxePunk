package haxepunk.inputs;

import haxe.ds.IntMap;

/**
 * Defines a specific button.
 */
private enum ButtonDef
{
	Identifier(id:String);
	MouseButton(button:Int);
	GamepadButton(button:Int);
	Key(key:Int);
}

/**
 * Represent any of the following types: String, Key, MouseButton, GamepadButton and Gesture.
 */
abstract ButtonType(ButtonDef)
{
	public inline function new(e:ButtonDef) { this = e; }
	public var type(get, never):ButtonDef;

	@:to inline function get_type() { return this; }

	@:from static function fromString(id:String) { return new ButtonType(Identifier(id)); }
	@:from static function fromMouseButton(button:MouseButton) { return new ButtonType(MouseButton(button)); }
	@:from static function fromKey(key:Key) { return new ButtonType(Key(key)); }
	@:from static function fromGamepadButton(button:GamepadButton) { return new ButtonType(GamepadButton(button)); }
}

/**
 * The types of value for an input.
 */
@:enum abstract ButtonValue(Int)
{
	var On = 0;
	var Pressed = 1;
	var Released = 2;
}

/**
 * Store the values on, pressed and released for a mouse button.
 */
@:allow(haxepunk.inputs)
class ButtonState
{
	public var on:Int = 0;
	public var pressed:Int = 0;
	public var released:Int = 0;

	private function new() { }

	public function value(v:ButtonValue):Int
	{
		return switch (v)
		{
			case ButtonValue.On: return on;
			case ButtonValue.Pressed: return pressed;
			case ButtonValue.Released: return released;
		};
	}
}


@:allow(haxepunk.inputs)
class ButtonManager
{
	/**
	 * Return the value for a mouse button.
	 *
	 * @param button The mouse button to check
	 * @param v The value to get
	 * @return The value of [v] for [button]
	 */
	private inline function value(button:Int, v:ButtonValue):Int
	{
		if (button < 0) // Any
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
			return getButtonState(button).value(v);
		}
	}

	/**
	 * Gets a mouse state object from a button number.
	 */
	private function getButtonState(button:Int):ButtonState
	{
		var state:ButtonState;
		if (_states.exists(button))
		{
			state = _states.get(button);
		}
		else
		{
			state = new ButtonState();
			_states.set(button, state);
		}
		return state;
	}

	/**
	 * Updates the mouse state.
	 */
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

	private var _states:IntMap<ButtonState> = new IntMap<ButtonState>();
}
