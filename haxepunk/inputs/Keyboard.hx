package haxepunk.inputs;

/**
 * Get information on the keyboard input.
 */
@:allow(haxepunk.inputs)
class Keyboard extends ButtonManager
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
	public static inline function nameOf(key:Key):String
	{
		return key.toString();
	}

	/**
	 * Setup the keyboard input support.
	 */
	private function new() { }

	/**
	 * onKeyDown event.
	 */
	private function onKeyDown(keycode:Int, modifiers:Int):Void
	{
		getButtonState(keycode).pressed += 1;
		last = keycode;
		switch (keycode)
		{
			case Key.ENTER:
				buffer += "\n";
			case Key.BACKSPACE:
				buffer = buffer.substr(0, -1);
		}
	}

	/**
	 * onKeyUp event.
	 */
	private function onKeyUp(keycode:Int, modifiers:Int):Void
	{
		getButtonState(keycode).released += 1;
		last = keycode;
	}

	/**
	 * onTextInput event.
	 */
	private function onTextInput(text:String):Void
	{
		buffer += text;
	}

}
