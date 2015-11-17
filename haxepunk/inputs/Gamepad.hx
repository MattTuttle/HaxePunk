package haxepunk.inputs;

import haxe.ds.IntMap;
import haxepunk.math.Vector3;
import haxepunk.inputs.InputState;

@:allow(haxepunk.inputs)
class Gamepad
{
	/** Number of connected gamepads. */
	public static var numberConnected(default, null):Int;

	/** Holds the last button detected. */
	public static var last(default, null):GamepadButton = NONE;

	/**
	 * Globally unique identifier for device.
	 */
	public var guid(default, null):String;
	/**
	 * Human-friendly name for controller.
	 */
	public var name(default, null):String;
	/**
	 * Connected id of the controller.
	 */
	public var id(default, null):Int;

	/** Determines the joystick's deadZone. Anything under this value will be considered 0 to prevent jitter. */
	public var deadZone:Float = 0.1;

	/** Each axis contained in an array. */
	public var axis(default, null):IntMap<Float>;

	/** If the gamepad is connected. */
	public var connected(default, null):Bool = true;

	public function new(name:String, id:Int, guid:String)
	{
		this.guid = guid;
		this.name = name;
		this.id = id;
		trace(guid, name, id);
		axis = new IntMap<Float>();
		numberConnected += 1;
	}

	private function onButtonUp(button:Int):Void
	{
		getInputState(button).released += 1;
		last = cast button;
	}

	private function onButtonDown(button:Int):Void
	{
		getInputState(button).pressed += 1;
		last = cast button;
	}

	private function onDisconnect():Void
	{
		numberConnected -= 1;
		connected = false;
	}

	private function onAxisMove(axis:Int, value:Float):Void
	{
		if (Math.abs(value) > deadZone)
		{
			this.axis.set(axis, value);
		}
	}

	/**
	 * Return the value for a mouse button.
	 *
	 * @param button The mouse button to check
	 * @param v The value to get
	 * @return The value of [v] for [button]
	 */
	private inline function value(button:GamepadButton, v:InputValue):Int
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
			return getInputState(cast button).value(v);
		}
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

	/**
	 * Returns the name of the gamepad button.
	 *
	 * Examples:
	 * Gamepad.nameOf(GamepadButton.LEFT);
	 * Gamepad.nameOf(GamepadButton.last);
	 *
	 * @param button The gamepad button to name
	 * @return The name
	 */
	public static function nameOf(button:GamepadButton):String
	{
		if (button < 0) // ANY || NONE
		{
			return "";
		}
		else
		{
			var v:Int = cast button;
			return "BUTTON " + v;
		}
	}

	private var _states:IntMap<InputState> = new IntMap<InputState>();

}
