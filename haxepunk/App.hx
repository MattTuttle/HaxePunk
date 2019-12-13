package haxepunk;

interface App
{
	public var fullscreen(get, set):Bool;

	public function init(engine:Engine):Void;

	public function getTimeMillis():Float;
	public function getMemoryUse():Float;

	public function multiTouchSupported():Bool;

	public function getMouseX():Float;
	public function getMouseY():Float;
}
