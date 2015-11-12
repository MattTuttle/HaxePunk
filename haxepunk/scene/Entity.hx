package haxepunk.scene;

import haxepunk.graphics.Graphic;
import haxepunk.graphics.SpriteBatch;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;

class Entity extends SceneNode
{

	public var clipRect:Rectangle;
	public var mask(default, null):Mask;
	public var collidable:Bool = true;

	public var drawable:Bool = false;

	public var graphic(default, set):Graphic;
	private inline function set_graphic(value:Graphic):Graphic
	{
		drawable = value != null;
		return graphic = value;
	}

	public var layer(default, set):Float;
	private inline function set_layer(value:Float) { return layer = value; }

	/**
	 * Generate world boundaries based on applied mask
	 */
	public var bounds(get, never):Rectangle;
	private function get_bounds():Rectangle {
		if (mask == null)
		{
			_bounds.x = x;
			_bounds.y = y;
			_bounds.width = _bounds.height = 0;
		}
		else
		{
			var offset = position + mask.origin,
				min = offset + mask.min,
				max = offset + mask.max;
			_bounds.left = min.x;
			_bounds.right = max.x;
			_bounds.top = min.y;
			_bounds.bottom = max.y;
		}
		return _bounds;
	}

	/**
	 * The collision group, used for collision checking.
	 */
	public var group(get, set):String;
	private inline function get_group():String { return _group; }
	private function set_group(value:String):String
	{
		if (_group != value)
		{
			if (scene == null)
			{
				_group = value;
			}
			else
			{
				if (_group != "") scene.removeGroup(this);
				_group = value;
				if (value != "") scene.addGroup(this);
			}
		}
		return _group;
	}

	/**
	 * The entity name
	 */
	public var name(get, set):String;
	private inline function get_name():String { return _name; }
	private function set_name(value:String):String
	{
		if (_name != value)
		{
			if (scene == null)
			{
				_name = value;
			}
			else
			{
				if (_name != "") scene.unregisterName(this);
				_name = value;
				if (value != "") scene.registerName(this);
			}
		}
		return _name;
	}

	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		super(x, y, z);
		layer = z;
		mask = new Box();
	}

	public function toString():String
	{
		return _name;
	}

	/**
	 * Add a Mask to the Entity.
	 * @return The Mask that was added.
	 */
	public function addMask(mask:Mask):Mask
	{
		return this.mask = mask;
	}

	/**
	 * Add a Graphic to the Entity.
	 * @return The Graphic that was added.
	 */
	public function addGraphic(graphic:Graphic):Graphic
	{
		if (this.graphic == null)
		{
			this.graphic = graphic;
		}
		else if (Std.is(this.graphic, GraphicList))
		{
			cast(this.graphic, GraphicList).add(graphic);
		}
		else
		{
			this.graphic = new GraphicList([this.graphic, graphic]);
		}
		return this.graphic;
	}

	/**
	 * Draw the entity if a graphic exists
	 */
	public function draw(batch:SpriteBatch)
	{
		if (graphic == null) return;
		if (clipRect != null)
		{
			batch.end();
			// TODO: don't calculate this every frame!!
			// convert from screen to window coordinates
			var vec = new Vector3(clipRect.x, clipRect.y);
			var tl = scene.camera.cameraToScreen(vec); // top left
			vec.x = clipRect.x + clipRect.width;
			vec.y = clipRect.y + clipRect.height;
			var br = scene.camera.cameraToScreen(vec); // bottom right
			var rect = new Rectangle(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
			// draw with scissor test
			Renderer.setScissor(rect);
			batch.begin();
			graphic.draw(batch, position);
			batch.end();
			Renderer.setScissor();
		}
		else
		{
			graphic.draw(batch, position);
		}
	}

	/**
	 * Moves the Entity by the amount given.
	 * @param	point		Offset vector.
	 */
	public function moveBy(point:Vector2):Void
	{
		position += point;
	}

	/**
	 * Moves the Entity to the position.
	 * @param	point		destination.
	 */
	public function moveTo(point:Vector2):Void
	{
		moveBy(position - point);
	}

	/**
	 * Moves towards the target position.
	 * @param	point		target position.
	 * @param	amount		Amount to move.
	 */
	public function moveTowards(point:Vector2, amount:Float):Void
	{
		var delta:Vector2 = point - position;
		if (delta.length > amount)
		{
			// TODO: don't calculate length twice?
			delta.normalize(amount);
		}
		moveBy(delta);
	}

	/**
	 * Moves at an angle by a certain amount, retaining integer values for its x and y.
	 * @param	angle		Angle to move at in degrees.
	 * @param	amount		Amount to move.
	 */
	public inline function moveAtAngle(angle:Float, amount:Float):Void
	{
		angle *= Math.RAD;
		var direction = new Vector2(Math.cos(angle), Math.sin(angle));
		direction *= amount;
		moveBy(direction);
	}

	/**
	 *
	 */
	public function collidePoint(point:Vector3):Bool
	{
		if (mask == null) return false;
		var vec = point - position;
		return mask.containsPoint(vec);
	}

	public function intersects(other:Mask):Bool
	{
		if (mask == null) return false;
		mask.origin += position;
		var result =  mask.intersects(other);
		mask.origin -= position;
		return result;
	}

	/**
	 * Checks for a collision against an Entity group.
	 * @param	group		The Entity group to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collide(?group:String, ?offset:Vector3):Entity
	{
		// check that the entity has been added to a scene
		// if (scene == null) return null;
		//
		// var entities = scene.entitiesForGroup(group);
		// if (!collidable || entities == null) return null;
		//
		// var _x = hitbox.x, _y = hitbox.x;
		// offset = (offset == null ? position : offset + position);
		// hitbox.min += offset;
		// hitbox.max += offset;
		//
		// for (e in entities)
		// {
		// 	if (e.collidable && e != this)
		// 	{
		// 		e.hitbox.min += e.position;
		// 		e.hitbox.max += e.position;
		// 		var result = e.hitbox.intersects(hitbox);
		// 		e.hitbox.min -= e.position;
		// 		e.hitbox.max -= e.position;
		//
		// 		if (result && (mask == null || e.mask != null && mask.intersects(e.mask)))
		// 		{
		// 			hitbox.min -= offset;
		// 			hitbox.max -= offset;
		// 			return e;
		// 		}
		// 	}
		// }
		//
		// hitbox.min -= offset;
		// hitbox.max -= offset;
		return null;
	}

	/**
	 * Updates the Entity.
	 */
	public function update():Void { }

	private var _group:String = "";
	private var _name:String = "";
	private var _bounds:Rectangle = new Rectangle();

}
