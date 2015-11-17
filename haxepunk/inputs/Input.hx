package haxepunk.inputs;

import haxepunk.inputs.InputState;
import haxepunk.inputs.Keyboard;
import haxepunk.inputs.Mouse;
import lime.ui.Window;

/**
 * Either enum used by InputType.
 */
private enum EitherInput
{
	String(s:String);
	MouseButton(mb:MouseButton);
	GamepadButton(gb:GamepadButton);
	Key(k:Key);
}

/**
 * Represent any of the following types: String, Key, MouseButton, GamepadButton and Gesture.
 */
private abstract InputType(EitherInput)
{
	public inline function new(e:EitherInput) { this = e; }
	public var type(get, never):EitherInput;

	@:to inline function get_type() { return this; }

	@:from static function fromString(s:String) { return new InputType(String(s)); }
	@:from static function fromMouseButton(mb:MouseButton) { return new InputType(MouseButton(mb)); }
	@:from static function fromGamepadButton(gb:GamepadButton) { return new InputType(GamepadButton(gb)); }
	@:from static function fromKey(k:Key) { return new InputType(Key(k)); }
}

/**
 * Manages the Input from Keyboard, Mouse, Touch and Gamepad.
 * Allow to check the state of Key, MouseButton, GamepadButton and Gesture.
 */
class Input
{

	public var keyboard(default, null):Keyboard;
	public var mouse(default, null):Mouse;
	public var gamepads(default, null):Array<Gamepad>;

	/**
	 * Check if an input is held down.
	 *
	 * @param input An input to check for
	 * @return If [input] is held down
	 */
	public inline function check(input:InputType):Bool
	{
		return value(input, InputValue.On) > 0 || value(input, InputValue.Pressed) > 0;
	}

	/**
	 * Defines a new input.
	 *
	 * @param name String to map the input to
	 * @param keys The inputs to use for the Input, don't use string in the array
	 * @param merge If the input is already defined merge the arrays instead of replacing it
	 */
	public function define(name:String, inputs:Array<InputType>, merge:Bool=false):Void
	{
		for (input in inputs)
		{
			switch (input.type)
			{
				case String(_):
					throw "Input.define can't have strings in the [inputs] array.";

				default:
			}
		}

		if (!merge || !_defines.exists(name))
		{
			_defines.set(name, inputs);
		}
		else
		{
			var existing = _defines.get(name);

			for (input in inputs)
			{
				if (existing.indexOf(input) == -1) // Not already in the array
				{
					existing.push(input);
				}
			}

			_defines.set(name, existing);
		}
	}

	/**
	 * How many times an input was pressed this frame.
	 *
	 * @param input An input to check for
	 * @return The number of times [input] was pressed
	 */
	public inline function pressed(input:InputType):Int
	{
		return value(input, InputValue.Pressed);
	}

	/**
	 * How many times an input was released this frame.
	 *
	 * @param input An input to check for
	 * @return The number of times [input] was released
	 */
	public inline function released(input:InputType):Int
	{
		return value(input, InputValue.Released);
	}



	/**
	 * Init the input systems.
	 */
	@:allow(haxepunk.Window)
	private function new(?window:Window)
	{
		keyboard = new Keyboard();
		mouse = new Mouse();
		gamepads = new Array<Gamepad>();
#if !unit_test
		// Register keyboard events
		window.onKeyDown.add(keyboard.onKeyDown);
		window.onKeyUp.add(keyboard.onKeyUp);
		// window.onTextInput.add(onTextInput);

		// Register mouse events
		window.onMouseMove.add(mouse.onMouseMove);
		window.onMouseDown.add(mouse.onMouseDown);
		window.onMouseUp.add(mouse.onMouseUp);
		window.onMouseWheel.add(mouse.onMouseWheel);

		lime.ui.Gamepad.onConnect.add(addGamepad);
#end
	}

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
	 * @param input The input to test against
	 * @param v The value to get
	 * @return The value [v] for the input [input]
	 */
	private function value(input:InputType, v:InputValue):Int
	{
		switch (input.type)
		{
			case String(name):
				if (_defines.exists(name))
				{
					var sum = 0;

					for (i in _defines.get(name))
					{
						sum = sum + subsystemValue(i, v);
					}

					return sum;
				}
				else
				{
					#if debug trace('[Warning] Input has no define of name "$name"'); #end
					return 0;
				}

			default: // not a string
				return subsystemValue(input, v);
		}
		return 0;
	}

	/**
	 * Get a value from an input, ignore string value.
	 *
	 * @param input The input to test against, if it's a String returns 0
	 * @param v The value to get
	 * @return The value [v] for the input [input]
	 */
	private function subsystemValue(input:InputType, v:InputValue):Int
	{
		return switch (input.type)
		{
			case String(name):
				0; // ignore strings

			case Key(k):
				keyboard.value(k, v);

			case MouseButton(mb):
				mouse.value(mb, v);

			case GamepadButton(gb):
				var val:Int = 0;
				for (gamepad in gamepads)
				{
					val += gamepad.value(gb, v);
				}
				val;

			/*case Gesture(g):
				Touch.value(g, v);*/
		}
	}

	/**
	 * Update all input subsystems.
	 */
	@:allow(haxepunk.Window)
	private function update():Void
	{
		keyboard.update();
		mouse.update();
		for (i in 0...gamepads.length)
		{
			var gamepad = gamepads[i];
			if (gamepad.connected)
			{
				gamepad.update();
			}
		}
		//Touch.update();
	}

	/** Stocks the inputs the user defined using its name as key. */
	private var _defines = new Map<String, Array<InputType>>();
}
