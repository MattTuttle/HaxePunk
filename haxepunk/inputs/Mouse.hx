package haxepunk.inputs;

import haxe.ds.IntMap;
import lime.ui.Window;

import haxepunk.inputs.Input;
import haxepunk.inputs.InputState;
import haxepunk.math.*;

/**
 * Get information on the mouse input.
 */
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
	public function nameOf(button:MouseButton):String
	{
		if (button > 2) // The button isn't defined in MouseButton
		{
			var v:Int = cast button;
			return "BUTTON " + v;
		}

		return switch(button)
		{
			case ANY:
				"";

			case LEFT:
				"LEFT";

			case MIDDLE:
				"MIDDLE";

			case RIGHT:
				"RIGHT";
		}
	}



	/**
	 * Setup the mouse input support.
	 */
	@:allow(haxepunk.inputs.Input)
	private function new(window:Window):Void
	{
		// Register the events from lime
		window.onMouseMove.add(onMouseMove);
		window.onMouseDown.add(onMouseDown);
		window.onMouseUp.add(onMouseUp);
		window.onMouseWheel.add(onMouseWheel);
	}

	/**
	 * Return the value for a mouse button.
	 *
	 * @param button The mouse button to check
	 * @param v The value to get
	 * @return The value of [v] for [button]
	 */
	@:allow(haxepunk.inputs.Input)
	private inline function value(button:MouseButton, v:InputValue):Int
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
	 * Updates the mouse state.
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

		// Reset wheelDelta
		wheelDeltaX = wheelDeltaY = 0;
	}

	/**
	 * Lime onMouseMove event.
	 */
	private inline function onMouseMove(x:Float, y:Float):Void
	{
		position.x = x;
		position.y = y;
	}

	/**
	 * Lime onMouseDown event.
	 */
	private function onMouseDown(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y);

		getInputState(button).pressed += 1;
		last = cast button;
	}

	/**
	 * Lime onMouseUp event.
	 */
	private function onMouseUp(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y);

		getInputState(button).released += 1;
		last = cast button;
	}

	/**
	 * Lime onMouseWheel event.
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
