package haxepunk;

import haxepunk.graphics.Image;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.hardware.Renderer;
import haxepunk.screen.ScaleMode;

/**
 * Container for the main screen buffer.
 * To be used through `HXP.screen`.
 */
@:allow(haxepunk.screen)
class Screen
{
	/**
	 * Controls how the game scale changes when the window is resized.
	 */
	public var scaleMode(default, set):ScaleMode = new ScaleMode();
	inline function set_scaleMode(value:ScaleMode):ScaleMode
	{
		needsResize = true;
		return scaleMode = value;
	}

	/**
	 * For hardware rendering.
	 */
	public var renderer:Renderer = new Renderer();

	/**
	 * Constructor.
	 */
	@:allow(haxepunk)
	function new(width:Int = 0, height:Int = 0)
	{
		scaleMode.setBaseSize(width, height);
		resize(width, height);
	}

	/**
	 * Resizes the screen by recreating the bitmap buffer.
	 */
	@:dox(hide)
	@:allow(haxepunk.Engine)
	function resize(width:Int, height:Int)
	{
		scaleMode.resizeScreen(this, width, height);

		HXP.width = Std.int(this.width / this.fullScaleX);
		HXP.height = Std.int(this.height / this.fullScaleY);

#if !unit_test
		HXP.engine.scrollRect.width = this.width;
		HXP.engine.scrollRect.height = this.height;
#end

		needsResize = false;
	}

	@:dox(hide)
	public function update()
	{
		if (needsResize)
		{
			resize(HXP.windowWidth, HXP.windowHeight);
		}
	}

	/**
	 * X offset of the screen.
	 */
	public var x(default, set):Int = 0;
	function set_x(value:Int):Int
	{
		#if !unit_test HXP.engine.x = value; #end
		return x = value;
	}

	/**
	 * Y offset of the screen.
	 */
	public var y(default, set):Int = 0;
	function set_y(value:Int):Int
	{
		#if !unit_test HXP.engine.y = value; #end
		return y = value;
	}

	/**
	 * X scale of the screen.
	 */
	public var scaleX(default, set):Float = 1;
	function set_scaleX(value:Float):Float
	{
		if (scaleX == value) return value;
		scaleX = value;
		fullScaleX = scaleX * scale;
		needsResize = true;
		return scaleX;
	}

	/**
	 * Y scale of the screen.
	 */
	public var scaleY(default, set):Float = 1;
	function set_scaleY(value:Float):Float
	{
		if (scaleY == value) return value;
		scaleY = value;
		fullScaleY = scaleY * scale;
		needsResize = true;
		return scaleY;
	}

	/**
	 * Scale factor of the screen. Final scale is scaleX * scale by scaleY * scale, so
	 * you can use this factor to scale the screen both horizontally and vertically.
	 */
	public var scale(default, set):Float = 1;
	function set_scale(value:Float):Float
	{
		if (scale == value) return value;
		scale = value;
		fullScaleX = scaleX * scale;
		fullScaleY = scaleY * scale;
		needsResize = true;
		return scale;
	}

	/**
	 * Final X scale value of the screen
	 */
	public var fullScaleX(default, null):Float = 1;

	/**
	 * Final Y scale value of the screen
	 */
	public var fullScaleY(default, null):Float = 1;

	/**
	 * True if the scale of the screen has changed.
	 */
	@:dox(hide)
	public var needsResize(default, null):Bool = false;

	/**
	 * Whether screen smoothing should be used or not.
	 */
	public var smoothing(get, set):Bool;
	function get_smoothing():Bool
	{
		return Atlas.smooth;
	}
	function set_smoothing(value:Bool):Bool
	{
		return Atlas.smooth = value;
	}

	/**
	 * Width of the screen.
	 */
	public var width(default, null):Int;

	/**
	 * Height of the screen.
	 */
	public var height(default, null):Int;

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(get, null):Int;
	function get_mouseX():Int return Std.int(HXP.engine.mouseX);

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(get, null):Int;
	function get_mouseY():Int return Std.int(HXP.engine.mouseY);

	/**
	 * Captures the current screen as an Image object.
	 * @return	A new Image object.
	 */
	public function capture():Image
	{
		throw "Screen.capture not currently supported";
	}
}
