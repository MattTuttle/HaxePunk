package backend.generic.render;

import haxepunk.Signal.Signal0;
import haxepunk.utils.Color;

interface Texture
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	public function getPixel(x:Int, y:Int):Color;
	public function setPixel(x:Int, y:Int, c:Color):Void;

	// for removing background from bitmap fonts
	public function removeColor(color:Color):Void;
	// used in Image.createCircle
	public function drawCircle(x:Float, y:Float, radius:Float):Void;

	public function bind():Void;
	public function dispose():Void;
}
