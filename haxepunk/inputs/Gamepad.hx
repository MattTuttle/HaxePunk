package haxepunk.inputs;

import haxe.ds.IntMap;
import haxepunk.math.*;

@:allow(haxepunk.inputs)
class Gamepad extends ButtonManager
{

	/**
	 * Holds the last button detected.
	 */
	public var last(default, null):Int = -1;

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

	/**
	 * Determines the joystick's deadZone.
	 * Anything under this value will be considered 0 to prevent jitter.
	 */
	public var deadZone:Float = 0.15;

	/**
	 * If the gamepad is connected.
	 */
	public var isConnected(default, null):Bool = true;

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
	public static inline function nameOf(button:GamepadButton):String
	{
		return button.toString();
	}

	public function new(name:String, id:Int, guid:String)
	{
		this.guid = guid;
		this.name = name;
		this.id = id;
		_axis = new IntMap<Float>();
	}

	/**
	 * Get the value of an axis.
	 * @param  The axis to poll.
	 * @return The value of the axis or 0 if not set.
	 */
	public function getAxis(axis:Int):Float
	{
		return _axis.exists(axis) ? _axis.get(axis) : 0;
	}

	/**
	 * Trigger when a button is released on the gamepad.
	 * @param button  The button that was released.
	 */
	private function onButtonUp(button:Int):Void
	{
		getButtonState(button).released += 1;
		last = button;
	}

	/**
	 * Trigger when a button is pressed on the gamepad.
	 * @param button  The button that was pressed.
	 */
	private function onButtonDown(button:Int):Void
	{
		getButtonState(button).pressed += 1;
		last = button;
	}

	/**
	 * Trigger when the gamepad is disconnected.
	 */
	private function onDisconnect():Void
	{
		isConnected = false;
	}

	/**
	 * Trigger when an axis on the gamepad is moved.
	 * @param axis   The axis that was moved.
	 * @param value  The value of the axis -1 to 1
	 */
	private function onAxisMove(axis:Int, value:Float):Void
	{
		var abs = Math.abs(value);

		// clamp (deadZone < axis < 1)
		if (abs < deadZone) value = 0;
		else if (abs > 1) value = Math.sign(value);

		_axis.set(axis, value);
	}

	/** Each axis contained in an array. */
	private var _axis(default, null):IntMap<Float>;

}
