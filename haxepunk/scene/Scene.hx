package haxepunk.scene;

import haxe.ds.StringMap;
import haxepunk.graphics.*;
import haxepunk.masks.Mask;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import haxepunk.graphics.SpriteBatch;
import haxepunk.utils.Time;

using haxepunk.utils.ArrayUtils;

class Scene
{

	/**
	 * The active camera to draw the scene.
	 * Will not change until the end of the frame.
	 */
	public var camera:Camera;

	/**
	 * The scene's sprite batcher.
	 */
	public var spriteBatch(default, null):SpriteBatch;

	public function new(width:Int=0, height:Int=0)
	{
		camera = new Camera(width, height);
		spriteBatch = new SpriteBatch();

		_added = new Array<Entity>();
		_removed = new Array<Entity>();
		_entities = new Array<Entity>();
		_layerList = new Array<Entity>();
		_groups = new StringMap<Array<Entity>>();
		_entityNames = new StringMap<Entity>();
	}

	/**
	 * Add a single entity to the scene.
	 * @param e The Entity to add.
	 */
	public function add(e:Entity):Void
	{
		_added.push(e);
	}

	/**
	 * Add a list of entities to the scene.
	 * @param list A list of Entity objects to add.
	 */
	public function addList(list:Array<Entity>):Void
	{
		for (e in list)
		{
			add(e);
		}
	}

	/**
	 * Remove a single entity from the scene.
	 * @param e The Entity to remove.
	 */
	public inline function remove(e:Entity):Void
	{
		e.remove = true;
	}

	/**
	 * Remove a list of entities from the scene.
	 * @param list A list of Entity objects to remove.
	 */
	public function removeList(list:Array<Entity>):Void
	{
		for (e in list)
		{
			remove(e);
		}
	}

	/**
	 * Remove all entities in the scene
	 */
	public function removeAll():Void
	{
		removeList(_entities);
	}

	/**
	 * Create an Entity object with a mask applied and add it to the scene.
	 * @param mask The Mask object to add.
	 * @param layer The layer on which to place the entity.
	 * @param x The x-axis position of the Entity.
	 * @param y The y-axis position of the Entity.
	 * @return The created and added Entity object.
	 */
	public function addMask(mask:Mask, layer:Float=0, x:Float=0, y:Float=0):Entity
	{
		var e = new Entity(x, y, layer);
		e.addMask(mask);
		add(e);
		return e;
	}

	/**
	 * Create an Entity object with a graphic applied and add it to the scene.
	 * @param graphic The Graphic object to add.
	 * @param layer The layer on which to place the entity.
	 * @param x The x-axis position of the Entity.
	 * @param y The y-axis position of the Entity.
	 * @return The created and added Entity object.
	 */
	public function addGraphic(graphic:Graphic, layer:Float=0, x:Float=0, y:Float=0):Entity
	{
		var e = new Entity(x, y);
		e.layer = layer;
		e.addGraphic(graphic);
		add(e);
		return e;
	}

	/**
	 * The number of entities in the Scene.
	 */
	public var entityCount(get, never):Int;
	private inline function get_entityCount():Int { return _entities.length; }

	/**
	 * An iterator of all the entities in the Scene.
	 */
	public var entities(get, never):Iterator<Entity>;
	private inline function get_entities():Iterator<Entity>
	{
		return _entities.iterator();
	}

	/**
	 * A list of Entity objects of the group.
	 * @param	group 		The group to check. If group is null, return all entities.
	 * @return 	An Entity iterator containing all entities of the requested group.
	 */
	public inline function entitiesForGroup(?group:String):Iterator<Entity>
	{
		return group == null ? entities : (_groups.exists(group) ? _groups.get(group).iterator() : [].iterator());
	}

	/**
	 * Returns the amount of Entities of the group are in the Scene.
	 * @param	group		The group (or Class group) to count.
	 * @return	How many Entities of group exist in the Scene.
	 */
	public inline function groupCount(group:String):Int
	{
		return _groups.exists(group) ? _groups.get(group).length : 0;
	}

	/**
	 * How many different groups have been added to the Scene.
	 */
	public var uniqueGroups(get, never):Int;
	private inline function get_uniqueGroups():Int
	{
		var i:Int = 0;
		for (group in _groups) i++;
		return i;
	}

	/**
	 * Pushes all Entities in the Scene of the group into the Array or Vector. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	group		The group to check.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getGroup<E:Entity>(group:String, into:Array<E>):Void
	{
		if (!_groups.exists(group)) return;
		var n:Int = into.length;
		for (e in _groups.get(group))
		{
			into[n++] = cast e;
		}
	}

	/** @private Adds Entity to the group list. */
	@:allow(haxepunk.scene.Entity)
	private function addGroup(e:Entity):Void
	{
		var list:Array<Entity>;
		// add to group list
		if (_groups.exists(e.group))
		{
			list = _groups.get(e.group);
		}
		else
		{
			list = new Array<Entity>();
			_groups.set(e.group, list);
		}
		list.push(e);
	}

	/** @private Removes Entity from the group list. */
	@:allow(haxepunk.scene.Entity)
	private function removeGroup(e:Entity):Void
	{
		if (!_groups.exists(e.group)) return;
		var list = _groups.get(e.group);
		list.remove(e);
		if (list.length == 0)
		{
			_groups.remove(e.group);
		}
	}

	/**
	 * Get entity by name
	 * @param name the entity name to find
	 * @return The Entity, if any, that matches the name given.
	 */
	public function getByName(name:String):Null<Entity>
	{
		return exists(name) ? _entityNames.get(name) : null;
	}

	/**
	 * Check if an entity exists by name
	 * @param name the entity name to check for existence
	 */
	public inline function exists(name:String):Bool
	{
		return _entityNames.exists(name);
	}

	/** @private Register the entities instance name. */
	@:allow(haxepunk.scene.Entity)
	private inline function registerName(e:Entity):Void
	{
		#if debug
		if (exists(e.name))
		{
			trace("WARN: Entity named '" + e.name + "' already exists!");
		}
		#end
		_entityNames.set(e.name, e);
	}

	/** @private Unregister the entities instance name. */
	@:allow(haxepunk.scene.Entity)
	private inline function unregisterName(e:Entity):Void
	{
		_entityNames.remove(e.name);
	}

	/**
	 * Find the entity origin point nearest to the given point, if any.
	 * @param	point		Point to check.
	 * @param	group		The collision group to search or all entities if null.
	 * @param	useBounds	Use the Entity Mask bounds.
	 * @return	The entity closest to the given point.
	 */
	public function nearestTo(point:Vector3, ?group:String, useBounds:Bool=false):Null<Entity>
	{
		var nearDist:Float = Math.FLOAT_MAX,
			dist:Float,
			near:Entity = null;
		for (e in entitiesForGroup(group))
		{
			if (useBounds)
			{
				var bounds = e.bounds;
				dist = Math.distanceRectPoint(point.x, point.y, bounds.x, bounds.y, bounds.width, bounds.height);
			}
			else
			{
				dist = Math.distanceSquared(point.x, point.y, e.x, e.y);
			}

			if (dist < nearDist)
			{
				nearDist = dist;
				near = e;
			}
		}
		return near;
	}

	/**
	 * Returns all entities found that collide with the position.
	 * @param	point	Point to check for collision.
	 * @param	group	The collision group to search or all entities if null.
	 * @return	A list of any entities that collide with the point.
	 */
	public function collidePoint(point:Vector3, ?group:String):Array<Entity>
	{
		var result = [];
		for (e in entitiesForGroup(group))
		{
			if (e.collidable && e.collidePoint(point))
			{
				result.push(e);
			}
		}
		return result;
	}

	/**
	 * Returns all entities found that collide with the Mask.
	 * @param	mask	Mask to use for collision checks.
	 * @param	group	The collision group to search or all entities if not specified.
	 * @return	A list of any entities that collide with the Mask.
	 */
	public function collideInto(mask:Mask, ?group:String):Array<Entity>
	{
		var result = [];
		for (e in entitiesForGroup(group))
		{
			if (e.collidable && e.intersects(mask))
			{
				result.push(e);
			}
		}
		return result;
	}

	private static function sortByLayer(a:Entity, b:Entity):Int
	{
		return Std.int(a.layer - b.layer);
	}

	/**
	 * Draws the scene
	 */
	public function draw()
	{
		spriteBatch.begin(camera.transform);
		for (e in _layerList)
		{
			if (e.drawable) e.draw(spriteBatch);
		}
		spriteBatch.end();
	}

	/**
	 * Captures the scene to an image file
	 * @param filename the name of the screenshot file to generate
	 */
	public function capture(filename:String):Void
	{
#if !(html5 || flash)
		try {
			var viewport = camera.viewport;
			var file = sys.io.File.write(filename);
			var format = filename.substr(filename.lastIndexOf(".") + 1);
			var image = Renderer.capture(viewport);
			var bytes = image.encode(format);
			file.writeBytes(bytes, 0, bytes.length);
			file.close();
		} catch (e:Dynamic) {
			trace("Failed to capture screen: " + e);
		}
#end
	}

	/**
	 * Updates the scene
	 * @param elapsed The elapsed time, in seconds, since the last update.
	 */
	public function update(window:Window):Void
	{
		updateEntities(window);
		camera.update();
	}

	/** @private Adds, updates, and removes entities from the scene */
	private inline function updateEntities(window:Window):Void
	{
		var e:Entity;

		// add any entities for this update
		for (i in 0..._added.length)
		{
			e = _added[i];
			_entities.push(e);
			_layerList.insertSortedKey(e, sortByLayer);
			e.scene = this;
			if (e.group != "") addGroup(e);
			if (e.name != "") registerName(e);
		}
		_added.clear();

		// update every entity
		for (i in 0..._entities.length)
		{
			e = _entities[i];
			if (e.remove)
			{
				_removed.push(e);
			}
			else
			{
				e.update(window);
				// remove need to call super.update() on base Entity
				if (e.graphic != null) e.graphic.update();
				// remove and add entity if layer changed
				if (e.layer != e.z)
				{
					e.z = e.layer; // keep z and layer matching
					_layerList.remove(e);
					_layerList.insertSortedKey(e, sortByLayer);
				}
			}
		}

		// remove any entities no longer used
		for (i in 0..._removed.length)
		{
			e = _removed[i];
			e.scene = null;
			_entities.remove(e);
			if (e.group != "") removeGroup(e);
			if (e.name != "") unregisterName(e);
		}
		_removed.clear();
	}

	private var _added:Array<Entity>;
	private var _removed:Array<Entity>;
	private var _entities:Array<Entity>;
	private var _layerList:Array<Entity>;
	private var _groups:StringMap<Array<Entity>>;
	private var _entityNames:StringMap<Entity>;

}
