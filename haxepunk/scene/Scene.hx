package haxepunk.scene;

import haxe.ds.StringMap;
import haxepunk.debug.Console;
import haxepunk.graphics.Graphic;
import haxepunk.graphics.Draw;
import haxepunk.masks.Mask;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import haxepunk.graphics.SpriteBatch;

class Scene
{

	public var camera:Camera;
	public var width:Int;
	public var height:Int;

	public function new(width:Int=0, height:Int=0)
	{
		camera = new Camera();
		_added = new Array<Entity>();
		_entities = new Array<Entity>();
		_types = new StringMap<Array<Entity>>();
		_entityNames = new StringMap<Entity>();
		_frameList = new Array<Float>();
		this.width = width;
		this.height = height;
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
	public function addMask(mask:Mask, layer:Int=0, x:Float=0, y:Float=0):Entity
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
	public function addGraphic(graphic:Graphic, layer:Int=0, x:Float=0, y:Float=0):Entity
	{
		var e = new Entity(x, y, layer);
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
	 * A list of Entity objects of the type.
	 * @param	type 		The type to check.
	 * @return 	An Entity iterator containing all entities of the requested type.
	 */
	public inline function entitiesForType(type:String):Iterator<Entity>
	{
		return _types.exists(type) ? _types.get(type).iterator() : null;
	}

	/**
	 * Returns the amount of Entities of the type are in the Scene.
	 * @param	type		The type (or Class type) to count.
	 * @return	How many Entities of type exist in the Scene.
	 */
	public inline function typeCount(type:String):Int
	{
		return _types.exists(type) ? _types.get(type).length : 0;
	}

	/**
	 * How many different types have been added to the Scene.
	 */
	public var uniqueTypes(get, never):Int;
	private inline function get_uniqueTypes():Int
	{
		var i:Int = 0;
		for (type in _types) i++;
		return i;
	}

	/**
	 * Pushes all Entities in the Scene of the type into the Array or Vector. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The type to check.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getType<E:Entity>(type:String, into:Array<E>):Void
	{
		if (!_types.exists(type)) return;
		var n:Int = into.length;
		for (e in _types.get(type))
		{
			into[n++] = cast e;
		}
	}

	/** @private Adds Entity to the type list. */
	@:allow(haxepunk.scene.Entity)
	private function addType(e:Entity)
	{
		var list:Array<Entity>;
		// add to type list
		if (_types.exists(e.type))
		{
			list = _types.get(e.type);
		}
		else
		{
			list = new Array<Entity>();
			_types.set(e.type, list);
		}
		list.push(e);
	}

	/** @private Removes Entity from the type list. */
	@:allow(haxepunk.scene.Entity)
	private function removeType(e:Entity)
	{
		if (!_types.exists(e.type)) return;
		var list = _types.get(e.type);
		list.remove(e);
		if (list.length == 0)
		{
			_types.remove(e.type);
		}
	}

	/**
	 * Get entity by name
	 * @param name the entity name to find
	 * @return The Entity, if any, that matches the name given.
	 */
	public function getByName(name:String):Entity
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
	private inline function registerName(e:Entity)
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

	private function sortByLayer(a:Entity, b:Entity):Int
	{
		return Std.int(a.layer - b.layer);
	}

	/**
	 * Draws the scene
	 */
	public function draw()
	{
		var e;
		Renderer.clear(camera.clearColor);
		for (i in 0..._entities.length)
		{
			e = _entities[i];
			if (e.drawable) e.draw();
		}
		if (Console.enabled) Console.instance.draw(this);
		SpriteBatch.flush();
		Renderer.present();

		var t = haxe.Timer.stamp() * 1000;
		_frameListSum += _frameList[_frameList.length] = Std.int(t - _frameLast);
		if (_frameList.length > 10) _frameListSum -= _frameList.shift();
		HXP.frameRate = 1000 / (_frameListSum / _frameList.length);
		_frameLast = t;
	}

	/**
	 * Captures the scene to an image file
	 * @param filename the name of the screenshot file to generate
	 */
	public function capture(filename:String):Void
	{
		try {
			var file = sys.io.File.write(filename);
			var format = filename.substr(filename.lastIndexOf(".") + 1);
			var bytes = Renderer.capture(0, 0, width, height).encode(format);
			file.writeBytes(bytes, 0, bytes.length);
			file.close();
		} catch (e:Dynamic) {
			trace("Failed to capture screen: " + e);
		}
	}

	/**
	 * Updates the scene
	 * @param elapsed The elapsed time, in seconds, since the last update.
	 */
	public function update(elapsed:Float):Void
	{
		updateEntities(elapsed);
		if (Console.enabled) Console.instance.update(this, elapsed);
		camera.update();
	}

	/** @private Adds, updates, and removes entities from the scene */
	private inline function updateEntities(elapsed:Float=0):Void
	{
		var removed = new Array<Entity>(),
			e:Entity;

		// add any entities for this update
		for (e in _added)
		{
			_entities.push(e);
			e.scene = this;
			if (e.type != "") addType(e);
			if (e.name != "") registerName(e);
		}
		_added.splice(0, _added.length); // clear added array

		var layerDirty = false;
		for (i in 0..._entities.length)
		{
			e = _entities[i];
			if (e.remove)
			{
				removed.push(e);
			}
			else
			{
				var layer = e.layer;
				e.update(elapsed);
				if (layer != e.layer)
				{
					layerDirty = true;
				}
				if (e._graphic != null) e._graphic.update(elapsed);
			}
		}
		if (layerDirty)
		{
			// TODO: only sort entities that changed
			_entities.sort(sortByLayer);
		}

		// remove any entities no longer used
		for (e in removed)
		{
			e.scene = null;
			_entities.remove(e);
			if (e.type != "") removeType(e);
			if (e.name != "") unregisterName(e);
		}
	}

	private var _frameLast:Float = 0;
	private var _frameListSum:Float = 0;
	private var _frameList:Array<Float>;

	private var _added:Array<Entity>;
	private var _entities:Array<Entity>;
	private var _types:StringMap<Array<Entity>>;
	private var _entityNames:StringMap<Entity>;

}
