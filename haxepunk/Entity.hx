package haxepunk;

import haxepunk.Signal.Signal0;
import haxepunk.ds.Maybe;
import haxepunk.graphics.Graphiclist;
import haxepunk.math.MathUtil;
import haxepunk.math.Vector2;

@:dox(hide)
@:forward(iterator)
abstract StringOrArray(Array<String>) to Array<String> from Array<String>
{
	@:from static function fromString(str:String):StringOrArray {
		return [str];
	}
}

/**
 * Main game Entity class updated by `Scene`.
 */
@:allow(haxepunk.Mask)
@:allow(haxepunk.Scene)
class Entity extends Tweener
{
	/**
	 * The entity's parent, if any. This entity's position will be offset by
	 * the parent's position.
	 * @since 4.0.0
	 */
	public var parent:Maybe<Entity>;

	public var camera(default, set):Maybe<Camera> = null;
	function set_camera(v:Maybe<Camera>):Maybe<Camera> return camera = v;

	/**
	 * If set, skip every N update frames.
	 */
	public var skipFrames:Int = 0;

	/**
	 * If the Entity should render.
	 */
	@:isVar public var visible(get, set):Bool = true;
	function get_visible() return visible && parent.map((p) -> p.visible, true);
	function set_visible(v:Bool) return visible = v;

	override function get_active() return active && parent.map((p) -> p.active, true);

	/**
	 * If the Entity should respond to collision checks.
	 */
	@:isVar public var collidable(get, set):Bool = true;
	function get_collidable() return collidable && parent.map((p) -> p.collidable, true);
	function set_collidable(v:Bool) return collidable = v;

	public var enabled(get, set):Bool;
	inline function get_enabled() return active && visible && collidable;
	inline function set_enabled(v:Bool) return active = visible = collidable = v;

	/**
	 * X position of the Entity in the Scene.
	 */
	@:isVar public var x(get, set):Float = 0;
	function get_x():Float
	{
		return parent.map((p) -> p.x, 0) + x + followCamera.map((cam) -> cam.x, 0);
	}
	function set_x(v:Float):Float
	{
		return x = (v - parent.map((p) -> p.x, 0));
	}

	/**
	 * Y position of the Entity in the Scene.
	 */
	@:isVar public var y(get, set):Float = 0;
	function get_y():Float
	{
		return parent.map((p) -> p.y, 0) + y + followCamera.map((cam) -> cam.y, 0);
	}
	function set_y(v:Float):Float
	{
		return y = (v - parent.map((p) -> p.y, 0));
	}

	/**
	 * Local X position. If this entity has a parent, this value is relative
	 * to the parent's position.
	 * @since 4.0.0
	 */
	public var localX(get, set):Float;
	function get_localX() return x - parent.map((p) -> p.x, 0);
	function set_localX(v:Float) return x = parent.map((p) -> p.x, 0) + v;

	/**
	 * Local Y position. If this entity has a parent, this value is relative
	 * to the parent's position.
	 * @since 4.0.0
	 */
	public var localY(get, set):Float;
	function get_localY() return y - parent.map((p) -> p.y, 0);
	function set_localY(v:Float) return y = parent.map((p) -> p.y, 0) + v;

	/**
	 * Set to the camera the entity should follow. If null it won't follow any camera.
	 */
	public var followCamera:Maybe<Camera> = null;

	/**
	 * Width of the Entity's hitbox.
	 */
	public var width:Int = 0;

	/**
	 * Height of the Entity's hitbox.
	 */
	public var height:Int = 0;

	/**
	 * X origin of the Entity's hitbox.
	 */
	public var originX:Int = 0;

	/**
	 * Y origin of the Entity's hitbox.
	 */
	public var originY:Int = 0;

	public var onAdd:Signal0 = new Signal0();
	public var onRemove:Signal0 = new Signal0();
	public var preUpdate:Signal0 = new Signal0();
	public var postUpdate:Signal0 = new Signal0();

	/**
	 * Constructor. Can be used to place the Entity and assign a graphic and mask.
	 * @param	x			X position to place the Entity.
	 * @param	y			Y position to place the Entity.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 */
	public function new(x:Float = 0, y:Float = 0, ?graphic:Graphic, ?mask:Mask)
	{
		super();
		this.x = x;
		this.y = y;

		originX = originY = 0;
		width = height = 0;
		_moveX = _moveY = 0;
		_type = "";
		_name = "";

		HITBOX = new Mask();

		layer = 0;

		this.graphic = graphic;
		this.mask = mask;
		HITBOX.parent = this;
		_class = Type.getClassName(Type.getClass(this));
	}

	/**
	 * Override this, called when the Entity is added to a Scene.
	 */
	public function added():Void {}

	/**
	 * Override this, called when the Entity is removed from a Scene.
	 */
	public function removed():Void {}

	/**
	 * Override this, called when the Scene is resized.
	 */
	public function resized():Void {}

	public function shouldUpdate():Bool
	{
		if (skipFrames == 0) return true;
		else if (++_frames % skipFrames == 0)
		{
			_frames %= skipFrames;
			return true;
		}
		else return false;
	}

	/**
	 * Updates the Entity.
	 */
	override public function update():Void {}

	/**
	 * Renders the Entity. If you override this for special behaviour,
	 * remember to call super.render() to render the Entity's graphic.
	 */
	public function render(camera:Camera):Void
	{
		graphic.may(function(g) {
			if (g.visible)
			{
				if (g.relative)
				{
					_point.x = x;
					_point.y = y;
				}
				else
				{
					_point.x = _point.y = 0;
				}
				g.doRender(_point, camera);
			}
		});
	}

	public function debugDraw(camera:Camera, selected:Bool=false)
	{
		if (!mask.exists() && width > 0 && height > 0 && collidable)
		{
			Mask.drawContext.lineThickness = 2;
			Mask.drawContext.setColor(0xff0000, 0.065);
			Mask.drawContext.rectFilled((x - camera.x - originX) * camera.screenScaleX, (y - camera.y - originY) * camera.screenScaleY, width * camera.screenScaleX, height * camera.screenScaleY);
			Mask.drawContext.setColor(0xff0000, 0.25);
			Mask.drawContext.rect((x - camera.x - originX) * camera.screenScaleX, (y - camera.y - originY) * camera.screenScaleY, width * camera.screenScaleX, height * camera.screenScaleY);
		}
		else
		{
			mask.may(function(m) {
				m.debugDraw(camera);
			});
		}
		Mask.drawContext.setColor(selected ? 0x00ff00 : 0xffffff, 1);
		Mask.drawContext.circle((x - camera.x) * camera.screenScaleX, (y - camera.y) * camera.screenScaleY, 3, 8);
	}

	function entityIteratorByTypes(types:StringOrArray):Iterator<Entity>
	{
		var entities = new Map<Entity, Bool>();
		scene.may((s) -> {
			for (type in types)
			{
				var typeEntities = s.entitiesForType(type);
				if (typeEntities != null)
				{
					for (e in typeEntities)
					{
						entities.set(e, true);
					}
				}
			}
		});
		return entities.keys();
	}

	inline function overlapsWithEntity(other:Entity):Bool
	{
		return x - originX + width > other.x - other.originX
			&& y - originY + height > other.y - other.originY
			&& x - originX < other.x - other.originX + other.width
			&& y - originY < other.y - other.originY + other.height;
	}

	inline function collidesWithEntity(other:Entity):Bool
	{
		return if (collidable && other.collidable
			&& other != this
			&& overlapsWithEntity(other))
		{
			if (mask.exists())
			{
				mask.unsafe().collide(other.mask.or(other.HITBOX));
			}
			else
			{
				other.mask.map(function(m) return m.collide(HITBOX), false);
			}
		}
		else false;
	}

	/**
	 * Checks for a collision against an Entity type.
	 * @param	types		The Entity type(s) to check for. A string or string array.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collide(types:StringOrArray, x:Float, y:Float):Maybe<Entity>
	{
		if (!collidable) return null;

		var result = null;

		var _x = this.x, _y = this.y;
		this.x = x; this.y = y;

		for (e in entityIteratorByTypes(types))
		{
			if (collidesWithEntity(e))
			{
				result = e;
				break;
			}
		}
		this.x = _x; this.y = _y;
		return result;
	}

	/**
	 * Checks for collision against multiple Entity types.
	 * @param	types		An Array or Vector of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	@:deprecated("Use collide instead of collideTypes")
	public function collideTypes(types:StringOrArray, x:Float, y:Float):Maybe<Entity>
	{
		return collide(types, x, y);
	}

	/**
	 * Checks if this Entity collides with a specific Entity.
	 * @param	e		The Entity to collide against.
	 * @param	x		Virtual x position to place this Entity.
	 * @param	y		Virtual y position to place this Entity.
	 * @return	The Entity if they overlap, or null if they don't.
	 */
	public function collideWith<E:Entity>(e:E, x:Float, y:Float):Maybe<E>
	{
		var _x = this.x, _y = this.y;
		this.x = x; this.y = y;

		var result = collidesWithEntity(e) ? e : null;
		this.x = _x; this.y = _y;
		return result;
	}

	/**
	 * Checks if this Entity overlaps the specified rectangle.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @return	If they overlap.
	 */
	public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Bool
	{
		if (x - originX + width >= rX &&
			y - originY + height >= rY &&
			x - originX <= rX + rWidth &&
			y - originY <= rY + rHeight)
		{
			return mask.map((mask) -> {
				var _x = this.x, _y = this.y;
				this.x = x; this.y = y;
				HXP.entity.x = rX;
				HXP.entity.y = rY;
				HXP.entity.width = Std.int(rWidth);
				HXP.entity.height = Std.int(rHeight);
				if (mask.collide(HXP.entity.HITBOX))
				{
					this.x = _x; this.y = _y;
					return true;
				}
				this.x = _x; this.y = _y;
				return false;
			}, true);
		}
		return false;
	}

	/**
	 * Checks if this Entity overlaps the specified position.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @return	If the Entity intersects with the position.
	 */
	public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool
	{
		if (pX >= x - originX &&
			pY >= y - originY &&
			pX < x - originX + width &&
			pY < y - originY + height)
		{
			if (!mask.exists()) return true;
			var _x = this.x, _y = this.y;
			this.x = x; this.y = y;
			HXP.entity.x = pX;
			HXP.entity.y = pY;
			HXP.entity.width = 1;
			HXP.entity.height = 1;
			// already check for existence
			if (mask.unsafe().collide(HXP.entity.HITBOX))
			{
				this.x = _x; this.y = _y;
				return true;
			}
			this.x = _x; this.y = _y;
			return false;
		}
		return false;
	}

	/**
	 * Populates an array with all collided Entities of a type. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideInto<E:Entity>(types:StringOrArray, x:Float, y:Float, array:Array<E>):Void
	{
		if (!collidable) return;

		var _x = this.x, _y = this.y;
		this.x = x; this.y = y;
		var n:Int = array.length;

		for (e in entityIteratorByTypes(types))
		{
			if (collidesWithEntity(e))
			{
				array[n++] = cast e;
			}
		}
		this.x = _x; this.y = _y;
	}

	/**
	 * Populates an array with all collided Entities of multiple types. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	types		An array of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 */
	@:deprecated("Use collideInto instead of collideTypesInto")
	public function collideTypesInto<E:Entity>(types:StringOrArray, x:Float, y:Float, array:Array<E>)
	{
		collideInto(types, x, y, array);
	}

	/**
	 * Remove the entity from the current scene
	 */
	public function removeFromScene():Void
	{
		scene.may((s) -> s.remove(this));
	}

	/**
	 * The Scene object this Entity has been added to.
	 */
	public var scene(default, null):Maybe<Scene>;

	/**
	 * Half the Entity's width.
	 */
	public var halfWidth(get, null):Float;
	inline function get_halfWidth():Float return width / 2;

	/**
	 * Half the Entity's height.
	 */
	public var halfHeight(get, null):Float;
	inline function get_halfHeight():Float return height / 2;

	/**
	 * The center x position of the Entity's hitbox.
	 */
	public var centerX(get, null):Float;
	inline function get_centerX():Float return left + halfWidth;

	/**
	 * The center y position of the Entity's hitbox.
	 */
	public var centerY(get, null):Float;
	inline function get_centerY():Float return top + halfHeight;

	/**
	 * The leftmost position of the Entity's hitbox.
	 */
	public var left(get, null):Float;
	inline function get_left():Float return x - originX;

	/**
	 * The rightmost position of the Entity's hitbox.
	 */
	public var right(get, null):Float;
	inline function get_right():Float return left + width;

	/**
	 * The topmost position of the Entity's hitbox.
	 */
	public var top(get, null):Float;
	inline function get_top():Float return y - originY;

	/**
	 * The bottommost position of the Entity's hitbox.
	 */
	public var bottom(get, null):Float;
	inline function get_bottom():Float return top + height;

	/**
	 * The rendering layer of this Entity. Layers are drawn in descending order.
	 * Backgrounds will have large (positive) numbers, foregrounds will have
	 * small (negative) numbers.
	 */
	public var layer(get, set):Int;
	inline function get_layer():Int return _layer;
	function set_layer(value:Int):Int
	{
		if (_layer == value) return _layer;
		scene.may((s) -> {
			s.removeRender(this);
			_layer = value;
			s.addRender(this);
		});
		return _layer = value;
	}

	/**
	 * The collision type, used for collision checking.
	 */
	public var type(get, set):String;
	inline function get_type():String return _type;
	function set_type(value:String):String
	{
		if (_type == value) return _type;
		scene.may((s) -> {
			if (_type != "") s.removeType(this);
			_type = value;
			if (value != "") s.addType(this);
		});
		return _type = value;
	}

	/**
	 * An optional Mask component, used for specialized collision. If this is
	 * not assigned, collision checks will use the Entity's hitbox by default.
	 */
	public var mask(default, set):Maybe<Mask>;
	function set_mask(value:Maybe<Mask>):Maybe<Mask>
	{
		if (mask == value) return value;
		mask.may(function(m) m.parent = null);
		mask = value;
		value.may(function(m) m.parent = this);
		return mask;
	}

	/**
	 * Graphical component to render to the screen.
	 */
	public var graphic:Maybe<Graphic>;

	/**
	 * An optional name for the entity.
	 */
	public var name(get, set):String;
	inline function get_name():String return _name;
	function set_name(value:String):String
	{
		if (_name == value) return _name;
		scene.may((s) -> {
			if (_name != "") s.unregisterName(this);
			_name = value;
			if (value != "") s.registerName(this);
		});
		return _name = value;
	}

	/**
	 * Adds the graphic to the Entity via a Graphiclist.
	 * @param	g		Graphic to add.
	 *
	 * @return	The added graphic.
	 */
	public function addGraphic(g:Graphic):Graphic
	{
		if (!graphic.exists())
		{
			graphic = g;
		}
		else if (Std.is(graphic, Graphiclist))
		{
			cast(graphic, Graphiclist).add(g);
		}
		else
		{
			var list:Graphiclist = new Graphiclist();
			list.add(graphic.unsafe()); // checked for existence above
			list.add(g);
			graphic = list;
		}
		return g;
	}

	/**
	 * Sets the Entity's hitbox properties.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	originX		X origin of the hitbox.
	 * @param	originY		Y origin of the hitbox.
	 */
	public inline function setHitbox(width:Int = 0, height:Int = 0, originX:Int = 0, originY:Int = 0)
	{
		this.width = width;
		this.height = height;
		this.originX = originX;
		this.originY = originY;
	}

	/**
	 * Sets the Entity's hitbox to match that of the provided object.
	 * @param	o		The object defining the hitbox (eg. an Image or Rectangle).
	 */
	public function setHitboxTo(o:Dynamic)
	{
		width = getInt(o, "scaledWidth", getInt(o, "width"));
		height = getInt(o, "scaledHeight", getInt(o, "height"));

		originX = getInt(o, "originX", -getInt(o, "x"));
		originY = getInt(o, "originY", -getInt(o, "y"));
	}

	// used for setHitboxTo and shouldn't be used for anything else
	@:dox(hide)
	function getInt(o:Dynamic, prop:String, defaultValue:Int=0):Int
	{
		var v = Reflect.getProperty(o, prop);
		return switch (Type.typeof(v))
		{
			case TInt: v;
			case TFloat: Std.int(v);
			default: defaultValue;
		}
	};


	/**
	 * Sets the origin of the Entity.
	 * @param	x		X origin.
	 * @param	y		Y origin.
	 */
	public inline function setOrigin(x:Int = 0, y:Int = 0)
	{
		originX = x;
		originY = y;
	}

	/**
	 * Center's the Entity's origin (half width & height).
	 */
	public inline function centerOrigin()
	{
		originX = Std.int(halfWidth);
		originY = Std.int(halfHeight);
	}

	/**
	 * Calculates the distance from another Entity.
	 * @param	e				The other Entity.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public inline function distanceFrom(e:Entity, useHitboxes:Bool = false):Float
	{
		if (!useHitboxes) return Math.sqrt((x - e.x) * (x - e.x) + (y - e.y) * (y - e.y));
		else return MathUtil.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
	}

	/**
	 * Calculates the distance from this Entity to the point.
	 * @param	px				X position.
	 * @param	py				Y position.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public inline function distanceToPoint(px:Float, py:Float, useHitbox:Bool = false):Float
	{
		if (!useHitbox) return Math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
		else return MathUtil.distanceRectPoint(px, py, x - originX, y - originY, width, height);
	}

	/**
	 * Calculates the distance from this Entity to the rectangle.
	 * @param	rx			X position of the rectangle.
	 * @param	ry			Y position of the rectangle.
	 * @param	rwidth		Width of the rectangle.
	 * @param	rheight		Height of the rectangle.
	 * @return	The distance.
	 */
	public inline function distanceToRect(rx:Float, ry:Float, rwidth:Float, rheight:Float):Float
	{
		return MathUtil.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
	}

	/**
	 * Gets the class name as a string.
	 * @return	A string representing the class name.
	 */
	public function toString():String
	{
		return _class;
	}

	/**
	 * Moves the Entity by the amount, retaining integer values for its x and y.
	 * @param	x			Horizontal offset.
	 * @param	y			Vertical offset.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveBy(x:Float, y:Float, ?solidType:StringOrArray, sweep:Bool = false):Void
	{
		_moveX += x;
		_moveY += y;
		x = Math.round(_moveX);
		y = Math.round(_moveY);
		_moveX -= x;
		_moveY -= y;
		if (solidType == null)
		{
			this.x += x;
			this.y += y;
		}
		else
		{
			var sign:Int, e:Maybe<Entity>;
			if (x != 0)
			{
				if (collidable && (sweep || collide(solidType, this.x + x, this.y) != null))
				{
					sign = x > 0 ? 1 : -1;
					while (x != 0)
					{
						e = collide(solidType, this.x + sign, this.y);
						if (e.exists())
						{
							if (moveCollideX(e.unsafe())) break;
							else this.x += sign;
						}
						else
						{
							this.x += sign;
						}
						x -= sign;
					}
				}
				else this.x += x;
			}
			if (y != 0)
			{
				if (collidable && (sweep || collide(solidType, this.x, this.y + y) != null))
				{
					sign = y > 0 ? 1 : -1;
					while (y != 0)
					{
						e = collide(solidType, this.x, this.y + sign);
						if (e.exists())
						{
							if (moveCollideY(e.unsafe())) break;
							else this.y += sign;
						}
						else
						{
							this.y += sign;
						}
						y -= sign;
					}
				}
				else this.y += y;
			}
		}
	}

	/**
	 * Moves the Entity to the position, retaining integer values for its x and y.
	 * @param	x			X position.
	 * @param	y			Y position.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveTo(x:Float, y:Float, ?solidType:StringOrArray, sweep:Bool = false)
	{
		moveBy(x - this.x, y - this.y, solidType, sweep);
	}

	/**
	 * Moves towards the target position, retaining integer values for its x and y.
	 * @param	x			X target.
	 * @param	y			Y target.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveTowards(x:Float, y:Float, amount:Float, ?solidType:StringOrArray, sweep:Bool = false)
	{
		_point.x = x - this.x;
		_point.y = y - this.y;
		if (_point.dot(_point) > amount * amount)
		{
			_point.normalize(amount);
		}
		moveBy(_point.x, _point.y, solidType, sweep);
	}

	/**
	 * Moves at an angle by a certain amount, retaining integer values for its x and y.
	 * @param	angle		Angle to move at in degrees.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveAtAngle(angle:Float, amount:Float, ?solidType:StringOrArray, sweep:Bool = false):Void
	{
		angle *= MathUtil.RAD;
		moveBy(Math.cos(angle) * amount, Math.sin(angle) * amount, solidType, sweep);
	}

	/**
	 * When you collide with an Entity on the x-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e		The Entity you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideX(e:Entity):Bool
	{
		return true;
	}

	/**
	 * When you collide with an Entity on the y-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e		The Entity you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideY(e:Entity):Bool
	{
		return true;
	}

	/**
	 * Clamps the Entity's hitbox on the x-axis.
	 * @param	left		Left bounds.
	 * @param	right		Right bounds.
	 * @param	padding		Optional padding on the clamp.
	 */
	public inline function clampHorizontal(left:Float, right:Float, padding:Float = 0)
	{
		if (x - originX < left + padding) x = left + originX + padding;
		if (x - originX + width > right - padding) x = right - width + originX - padding;
	}

	/**
	 * Clamps the Entity's hitbox on the y axis.
	 * @param	top			Min bounds.
	 * @param	bottom		Max bounds.
	 * @param	padding		Optional padding on the clamp.
	 */
	public inline function clampVertical(top:Float, bottom:Float, padding:Float = 0)
	{
		if (y - originY < top + padding) y = top + originY + padding;
		if (y - originY + height > bottom - padding) y = bottom - height + originY - padding;
	}

	/**
	 * Center graphic inside bounding rect.
	 */
	public function centerGraphicInRect():Void
	{
		graphic.may(function(g) {
			g.x = halfWidth;
			g.y = halfHeight;
		});
	}

	// Entity information.
	var _class:String;
	var _type:String;
	var _layer:Int = 0;
	var _name:String;
	var _frames:Int = -1;

	var _recycleNext:Entity;

	// Collision information.
	var HITBOX:Mask;
	var _moveX:Float = 0;
	var _moveY:Float = 0;

	static var _EMPTY:Entity = new Entity();
	static var _point:Vector2 = new Vector2();
}
