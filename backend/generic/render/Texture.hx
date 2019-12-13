package backend.generic.render;

import haxepunk.utils.Color;

interface Texture
{
	public var width:Int;
	public var height:Int;

	public function getPixel(x:Int, y:Int):Color;
	public function setPixel(x:Int, y:Int, c:Color):Void;

	// specialized functions, not on every platform
	public function removeColor(color:Color):Void;
	public function drawCircle(x:Float, y:Float, radius:Float):Void;

	public function bind():Void;
	public function dispose():Void;
}
