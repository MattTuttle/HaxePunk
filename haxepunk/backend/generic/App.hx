package haxepunk.backend.generic;

import haxepunk.Engine;

class App implements haxepunk.App
{
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	public function new() {}

	public function init(engine:Engine) {}

	public function showCursor() {}
	public function hideCursor() {}

	public function getTimeMillis():Float return 0;
	public function getMemoryUse():Float return 0;

	public function multiTouchSupported():Bool return false;

	public function getMouseX():Float return 0;
	public function getMouseY():Float return 0;
}
