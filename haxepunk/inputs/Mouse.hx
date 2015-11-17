package haxepunk.inputs;

import haxepunk.math.*;

/**
 * Get information on the mouse input.
 */
@:allow(haxepunk.inputs)
class Mouse extends ButtonManager
{
	/** Holds the last mouse button detected */
	public var last(default, null):MouseButton = MouseButton.ANY;

	/**
	 * The delta of the mouse wheel, 0 if it wasn't moved this frame
	 */
	public var wheelDelta(default, null):Vector3 = new Vector3();

	/**
	 * The position of the mouse in screen coordinates.
	 */
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
	 * Updates the mouse state.
	 */
	override private function update():Void
	{
		super.update();

		// Reset wheelDelta
		wheelDelta.x = wheelDelta.y = 0;
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

		getButtonState(button).pressed += 1;
		last = cast button;
	}

	/**
	 * onMouseUp event.
	 */
	private function onMouseUp(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y);

		getButtonState(button).released += 1;
		last = cast button;
	}

	/**
	 * onMouseWheel event.
	 */
	private function onMouseWheel(deltaX:Float, deltaY:Float):Void
	{
		wheelDelta.x = deltaX;
		wheelDelta.y = deltaY;
	}

}
