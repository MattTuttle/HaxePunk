package haxepunk;

import haxepunk.graphics.Image;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.screen.ScaleMode;
import haxepunk.utils.Color;

/**
 * Container for the main screen buffer. Can be used to transform the screen.
 * To be used through `HXP.screen`.
 */
class Screen
{
	/**
	 * Controls how the game scale changes when the window is resized.
	 */
	public var scaleMode:ScaleMode;

	/**
	 * Constructor.
	 */
	@:allow(haxepunk)
	function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		scaleMode = new ScaleMode();
	}

	/**
	 * Resizes the screen.
	 */
	@:dox(hide)
	@:allow(haxepunk.HXP)
	function resize(width:Int, height:Int)
	{
		var oldWidth:Int = this.width,
			oldHeight:Int = this.height;

		scaleMode.resize(width, height);

		width = Std.int((this.width + 0.5) / this.scaleX);
		height = Std.int((this.height + 0.5) / this.scaleY);
	}

	/**
	 * Refresh color of the screen.
	 */
	public var color:Color = Color.Black;

	/**
	 * X offset of the screen.
	 */
	public var x:Int = 0;

	/**
	 * Y offset of the screen.
	 */
	public var y:Int = 0;

	/**
	 * Width of the screen.
	 */
	@:allow(haxepunk.screen)
	public var width(default, null):Int = 0;

	/**
	 * Height of the screen.
	 */
	@:allow(haxepunk.screen)
	public var height(default, null):Int = 0;

	/**
	 * X scale of the screen.
	 */
	public var scaleX(default, set):Float = 1;
	function set_scaleX(value:Float):Float
	{
		if (value != scaleX) HXP.needsResize = true;
		return scaleX = value;
	}

	/**
	 * Y scale of the screen.
	 */
	public var scaleY(default, set):Float = 1;
	function set_scaleY(value:Float):Float
	{
		if (scaleY != value) HXP.needsResize = true;
		return scaleY = value;
	}

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(get, null):Int;
	inline function get_mouseX():Int return Std.int((HXP.app.getMouseX() - x) / scaleX);

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(get, null):Int;
	inline function get_mouseY():Int return Std.int((HXP.app.getMouseY() - y) / scaleY);

	/**
	 * Captures the current screen as an Image object.
	 * @return	A new Image object.
	 */
	public function capture():Image
	{
		throw "Screen.capture not currently supported";
	}
}
