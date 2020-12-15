package haxepunk;

import haxe.Int64;

/**
 * An interface that must be implemented by each target.
 *
 * New targets should start by implementing a new App and assigning it in
 * the `Engine.createApp` function. The implementation should go in the
 * `haxepunk.backend` package.
 *
 * In the init function this will handle things like window creation,
 * input handling, and starting the main rendering loop. Use other apps
 * for reference to see how they are handling events.
 */
interface App
{
	/** Sets if the application window should be fullscreen or windowed */
	public var fullscreen(get, set):Bool;

	/** Initialize the application. This is called at the end of Engine's constructor. */
	public function init(engine:Engine):Void;

	/** Get the time in milliseconds */
	public function getTimeMillis():Float;
	/** The current memory usage in bytes. Used by console but could be left unimplemented. */
	public function getMemoryUse():Int64;

	/** Show the mouse cursor */
	public function showCursor():Void;
	/** Hide the mouse cursor */
	public function hideCursor():Void;

	/** Returns the state of multi-touch support */
	public function multiTouchSupported():Bool;

	/** Returns the current horizontal mouse coordinate */
	public function getMouseX():Float;
	/** Returns the current vertical mouse coordinate **/
	public function getMouseY():Float;
}
