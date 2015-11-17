package haxepunk.inputs;

import haxe.ds.IntMap;
import haxepunk.inputs.Input;
import haxepunk.inputs.InputState;
import haxepunk.math.*;

/**
 * Get information on the mouse input.
 */
@:allow(haxepunk.inputs)
class Mouse
{
	/** Holds the last mouse button detected */
	public var last(default, null):MouseButton = MouseButton.ANY;

	/** The delta of the mouse wheel on the horizontal axis, 0 if it wasn't moved this frame */
	public var wheelDeltaX(default, null):Float = 0;

	/** The delta of the mouse wheel on the vertical axis, 0 if it wasn't moved this frame */
	public var wheelDeltaY(default, null):Float = 0;

	public var position(default, null):Vector3 = new Vector3();

	/** X position of the mouse on the screen */
	public var x(get, never):Float;
	private inline function get_x():Float { return position.x; }

	/** Y position of the mouse on the screen */
	public var y(get, never):Float;
	private inline function get_y():Float { return position.y; }

	/**
	 * Returns the name of the mouse button.
	 *
	 * Examples:
	 * Mouse.nameOf(MouseButton.LEFT);
	 * Mouse.nameOf(Mouse.last);
	 *
	 * @param button The mouse button to name
	 * @return The name
	 */
	public static inline function nameOf(button:MouseButton):String
	{
		return button.toString();
	}

	/**
	 * Setup the mouse input support.
	 */
	private function new() { }

	/**
	 * Return the value for a mouse button.
	 *
	 * @param button The mouse button to check
	 * @param v The value to get
	 * @return The value of [v] for [button]
	 */
	private inline function value(button:MouseButton, v:InputValue):Int
	{
		var button:Int = cast button;
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
			return getInputState(button).value(v);
		}
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

		// Reset wheelDelta
		wheelDeltaX = wheelDeltaY = 0;
	}

	/**
	 * onMouseMove event.
	 */
	private inline function onMouseMove(x:Float, y:Float):Void
	{
		position.x = x;
		position.y = y;
	}

	/**
	 * onMouseDown event.
	 */
	private function onMouseDown(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y);

		getInputState(button).pressed += 1;
		last = cast button;
	}

	/**
	 * onMouseUp event.
	 */
	private function onMouseUp(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y);

		getInputState(button).released += 1;
		last = cast button;
	}

	/**
	 * onMouseWheel event.
	 */
	private function onMouseWheel(deltaX:Float, deltaY:Float):Void
	{
		wheelDeltaX = deltaX;
		wheelDeltaY = deltaY;
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

	/** States for On,Pressed,Released for each button */
	private var _states:IntMap<InputState> = new IntMap<InputState>();
}
