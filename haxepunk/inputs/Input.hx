package haxepunk.inputs;

import haxe.ds.IntMap;
import haxepunk.inputs.ButtonManager;
import haxepunk.inputs.Gamepad;

/**
 * Manages the Input from Keyboard, Mouse, Touch and Gamepad.
 * Allow to check the state of Key, MouseButton, GamepadButton and Gesture.
 */
@:allow(haxepunk.inputs)
class Input
{

	public var keyboard(default, null):Keyboard;
	public var mouse(default, null):Mouse;
	public var touches(default, null):IntMap<Touch>;
	public var gamepads(default, null):Array<Gamepad>;

	/**
	 * Check if an input is held down.
	 *
	 * @param input An input to check for
	 * @return If [input] is held down
	 */
	public inline function check(input:ButtonType):Bool
	{
		return value(input, ButtonValue.On) > 0 || value(input, ButtonValue.Pressed) > 0;
	}

	/**
	 * How many times an input was pressed this frame.
	 *
	 * @param input An input to check for
	 * @return The number of times [input] was pressed
	 */
	public inline function pressed(input:ButtonType):Int
	{
		return value(input, ButtonValue.Pressed);
	}

	/**
	 * How many times an input was released this frame.
	 *
	 * @param input An input to check for
	 * @return The number of times [input] was released
	 */
	public inline function released(input:ButtonType):Int
	{
		return value(input, ButtonValue.Released);
	}

	/**
	 * Defines a button group using a string identifier.
	 *
	 * @param name    Identifier for the button group.
	 * @param inputs  The inputs to use for the group, can also reference other groups.
	 * @param merge   If the input is already defined, merge the arrays instead of replacing it.
	 */
	public function define(name:String, inputs:Array<ButtonType>, merge:Bool=false):Void
	{
		// only merge if previously defined
		if (merge && _defines.exists(name))
		{
			inputs = _defines.get(name).concat(inputs);
		}

		_defines.set(name, inputs);
	}

	/**
	 * Init the input systems.
	 */
	public function new()
	{
		keyboard = new Keyboard();
		mouse = new Mouse();
		touches = new IntMap<Touch>();
		gamepads = new Array<Gamepad>();
	}

#if lime
	private function onTouch(t:lime.ui.Touch)
	{
		var touch;
		if (touches.exists(t.id))
		{
			touch = touches.get(t.id);
		}
		else
		{
			touch = new Touch(t.id);
			touches.set(t.id, touch);
		}
		touch.x = t.x;
		touch.y = t.y;
		touch.dx = t.dx;
		touch.dy = t.dy;
		touch.device = t.device;
		touch.pressure = t.pressure;
	}

	@:allow(haxepunk.Window)
	private function register(?window:lime.ui.Window)
	{
		// Register keyboard events
		window.onKeyDown.add(keyboard.onKeyDown);
		window.onKeyUp.add(keyboard.onKeyUp);
		// window.onTextInput.add(onTextInput);

		// Register mouse events
		window.onMouseMove.add(mouse.onMouseMove);
		window.onMouseDown.add(mouse.onMouseDown);
		window.onMouseUp.add(mouse.onMouseUp);
		window.onMouseWheel.add(mouse.onMouseWheel);

		lime.ui.Touch.onStart.add(onTouch);
		lime.ui.Touch.onMove.add(onTouch);
		lime.ui.Touch.onEnd.add(function(t) { touches.remove(t.id); });

		lime.ui.Gamepad.onConnect.add(addGamepad);
	}
#end

	private function addGamepad(gp:lime.ui.Gamepad):Void
	{
		var gamepad = new Gamepad(gp.name, gp.id, gp.guid);
		gp.onAxisMove.add(gamepad.onAxisMove);
		gp.onButtonDown.add(gamepad.onButtonDown);
		gp.onButtonUp.add(gamepad.onButtonUp);
		gp.onDisconnect.add(gamepad.onDisconnect);
		gamepads.push(gamepad);
	}

	/**
	 * Get a value from an input.
	 *
	 * If [input] is a String returns the sum of the inputs in the define.
	 *
	 * @param input  The input to test against.
	 * @param v      The button state to get.
	 * @param depth  Used to determine if an infinite loop is detected. DO NOT PASS!
	 * @return The value [v] for the input [input]
	 */
	private function value(input:ButtonType, v:ButtonValue, depth:Int=0):Int
	{
		if (depth > 10) throw "Input define loop detected in value()!";
		var result = 0;
		switch (input.type)
		{
			case Identifier(name):
				if (_defines.exists(name))
				{
					for (i in _defines.get(name))
					{
						result += value(i, v, depth + 1);
					}
				}
				else
				{
					#if debug trace('[Warning] Input has no define of name "$name"'); #end
				}

			case Key(key):
				result = keyboard.value(key, v);

			case MouseButton(button):
				result = mouse.value(button, v);

			case GamepadButton(button):
				// TODO: find a way to select a gamepad
				for (gamepad in gamepads)
				{
					result += gamepad.value(button, v);
				}
		}
		return result;
	}

	/**
	 * Update all input subsystems.
	 */
	@:allow(haxepunk.Window)
	private function update():Void
	{
		keyboard.update();
		mouse.update();
		// TODO: remove disconnected gamepads?
		for (i in 0...gamepads.length)
		{
			var gamepad = gamepads[i];
			if (gamepad.isConnected)
			{
				gamepad.update();
			}
		}
	}

	/** Stocks the inputs the user defined using its name as key. */
	private var _defines = new Map<String, Array<ButtonType>>();
}
