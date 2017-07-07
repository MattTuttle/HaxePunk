package haxepunk;

import haxepunk.Entity;
import haxepunk.masks.Masklist;
import haxepunk.utils.DrawContext;
import haxepunk.math.Projection;
import haxepunk.math.Vector2;

/**
 * Base class for Entity collision masks.
 * Do not use this directly, instead use the classes in haxepunk.masks.*
 */
class Mask
{
	@:isVar public static var drawContext(get, null):DrawContext;
	static inline function get_drawContext()
	{
		if (drawContext == null)
		{
			drawContext = new DrawContext();
			drawContext.lineThickness = 2;
		}
		return drawContext;
	}

	/**
	 * The parent Entity of this mask.
	 */
	public var parent(get, set):Null<Entity>;
	inline function get_parent():Null<Entity>
	{
		return _parent != Entity._EMPTY ? _parent : null;
	}
	function set_parent(value:Entity):Null<Entity>
	{
		_parent = (value == null ? Entity._EMPTY : value);
		update();
		return value;
	}

	/**
	 * The parent Masklist of the mask.
	 */
	public var list:Masklist;

	/**
	 * Constructor.
	 */
	@:allow(haxepunk)
	function new()
	{
		_parent = Entity._EMPTY;
		_class = Type.getClassName(Type.getClass(this));
		_check = new Map<String, Dynamic -> Bool>();
		_check.set(Type.getClassName(Masklist), collideMasklist);
	}

	/**
	 * Checks for collision with another Mask.
	 * @param	mask	The other Mask to check against.
	 * @return	If the Masks overlap.
	 */
	public function collide(mask:Mask):Bool
	{
		var cbFunc:Dynamic -> Bool = _check.get(mask._class);
		if (cbFunc != null) return cbFunc(mask);

		cbFunc = mask._check.get(_class);
		if (cbFunc != null) return cbFunc(this);

		return collideMask(mask);
	}

	/** @private Collide against an Entity. */
	function collideMask(other:Mask):Bool
	{
		return _parent.x - _parent.originX + _parent.width > other._parent.x - other._parent.originX
			&& _parent.y - _parent.originY + _parent.height > other._parent.y - other._parent.originY
			&& _parent.x - _parent.originX < other._parent.x - other._parent.originX + other._parent.width
			&& _parent.y - _parent.originY < other._parent.y - other._parent.originY + other._parent.height;
	}

	function collideMasklist(other:Masklist):Bool
	{
		return other.collide(this);
	}

	/**
	 * Override this
	 */
	@:dox(hide)
	public function debugDraw(camera:Camera):Void {}

	/** Updates the parent's bounds for this mask. */
	@:dox(hide)
	public function update() {}

	@:dox(hide)
	public function project(axis:Vector2, projection:Projection):Void
	{
		var max:Float = Math.NEGATIVE_INFINITY,
			min:Float = Math.POSITIVE_INFINITY;

		var left = -_parent.originX * axis.x;
		var right = left + _parent.width * axis.x;
		var top = -_parent.originY * axis.y;
		var bottom = top + _parent.height * axis.y;

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

	// Mask information.
	var _class:String;
	var _check:Map<String, Dynamic -> Bool>;
	var _parent:Entity;
}
