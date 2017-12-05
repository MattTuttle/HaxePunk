package haxepunk.backend.generic;

import haxepunk.utils.Color;
import haxepunk.graphics.hardware.ImageData;

class App implements haxepunk.App
{
	public var audio = new NullAudioSystem();

	public var assets = new Assets();

	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	public function new() {}

	public function init() {}

	public function getTimeMillis():Float return 0;

	public function multiTouchSupported():Bool return false;

	public function createImageData(width:Int, height:Int, transparent:Bool, color:Color):Null<ImageData> return null;
	public function getImageData(name:String):Null<ImageData> return null;

	public function getMemory():Int return 0;

	public function showCursor() {}
	public function hideCursor() {}

	public function getMouseX():Float return 0;
	public function getMouseY():Float return 0;
}
