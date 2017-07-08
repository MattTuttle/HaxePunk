package haxepunk.masks;

import flash.geom.Point;
import haxepunk.Mask;
import haxepunk.utils.Draw;
import haxepunk.math.Projection;
import haxepunk.math.Vector2;

/** Uses parent's hitbox to determine collision.
 * This class is used internally by HaxePunk, you don't need to use this class because
 * this is the default behaviour of Entities without a Mask object.
 */
class Hitbox extends Mask
{
	/**
	 * Constructor.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	x			X offset of the hitbox.
	 * @param	y			Y offset of the hitbox.
	 */
	public function new(width:Int = 1, height:Int = 1, x:Int = 0, y:Int = 0)
	{
		super();
		_width = width;
		_height = height;
		_x = x;
		_y = y;
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}

	/** @private Collides against an Entity. */
	override function collideMask(other:Mask):Bool
	{
		var px:Float = _x + _parent.x,
			py:Float = _y + _parent.y;

		var ox = other._parent.originX + other._parent.x,
			oy = other._parent.originY + other._parent.y;

		return px + _width > ox
			&& py + _height > oy
			&& px < ox + other._parent.width
			&& py < oy + other._parent.height;
	}

	/** @private Collides against a Hitbox. */
	function collideHitbox(other:Hitbox):Bool
	{
		var px:Float = _x + _parent.x,
			py:Float = _y + _parent.y;

		var ox:Float = other._x + other._parent.x,
			oy:Float = other._y + other._parent.y;

		return px + _width > ox
			&& py + _height > oy
			&& px < ox + other._width
			&& py < oy + other._height;
	}

	/**
	 * X offset.
	 */
	public var x(get, set):Int;
	function get_x():Int return _x;
	function set_x(value:Int):Int
	{
		_x = value;
		update();
		return _x;
	}

	/**
	 * Y offset.
	 */
	public var y(get, set):Int;
	function get_y():Int return _y;
	function set_y(value:Int):Int
	{
		_y = value;
		update();
		return _y;
	}

	/**
	 * Width.
	 */
	public var width(get, set):Int;
	function get_width():Int return _width;
	function set_width(value:Int):Int
	{
		_width = value;
		update();
		return _width;
	}

	/**
	 * Height.
	 */
	public var height(get, set):Int;
	function get_height():Int return _height;
	function set_height(value:Int):Int
	{
		_height = value;
		update();
		return _height;
	}

	/** Updates the parent's bounds for this mask. */
	@:dox(hide)
	override public function update()
	{
		if (parent != null)
		{
			// update entity bounds
			_parent.originX = -_x;
			_parent.originY = -_y;
			_parent.width = _width;
			_parent.height = _height;
		}
		// update parent list
		if (list != null)
		{
			list.update();
		}
	}

	@:dox(hide)
	override public function debugDraw(camera:Camera):Void
	{
		if (parent != null)
		{
			Mask.drawContext.setColor(0xff0000, 0.25);
			Mask.drawContext.rectFilled((parent.x - camera.x + x) * camera.fullScaleX, (parent.y - camera.y + y) * camera.fullScaleY, width * camera.fullScaleX, height * camera.fullScaleY);
			Mask.drawContext.setColor(0xff0000, 0.5);
			Mask.drawContext.rect((parent.x - camera.x + x) * camera.fullScaleX, (parent.y - camera.y + y) * camera.fullScaleY, width * camera.fullScaleX, height * camera.fullScaleY);
		}
	}

	@:dox(hide)
	override public function project(axis:Vector2, projection:Projection):Void
	{
		var max:Float = Math.NEGATIVE_INFINITY,
			min:Float = Math.POSITIVE_INFINITY;

		var left = _x * axis.x;
		var right = left + width * axis.x;
		var top = _y * axis.y;
		var bottom = top + height * axis.y;

		inline function checkAxis(cur)
		{
			if (cur < min) min = cur;
			if (cur > max) max = cur;
		}

		checkAxis(left + top);
		checkAxis(right + top);
		checkAxis(left + bottom);
		checkAxis(right + bottom);

		projection.min = min;
		projection.max = max;
	}

	// Hitbox information.
	var _width:Int = 0;
	var _height:Int = 0;
	var _x:Int = 0;
	var _y:Int = 0;
}
