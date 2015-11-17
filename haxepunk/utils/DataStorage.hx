package haxepunk.utils;

import haxe.ds.StringMap;
import haxe.Json;

/**
 * A flat string map of values. It can be used to store state information and save it to disk.
 */
class DataStorage
{

    public function new()
    {
        _map = new StringMap<Dynamic>();
    }

    /**
     * Load the data store from disk or localStorage.
     * @param path  The path to a file or the name of the key to load from.
     */
    public function restore(path:String):Void
    {
        try
        {
#if html5
        fromJson(js.Broser.getLocalStorage().getItem(path));
#else
        fromJson(sys.io.File.getContent(path));
#end
        }
        catch (e:Dynamic)
        {
            Log.error("Failed to load data from " + path);
        }
    }

    /**
     * Save the data store to disk or localStorage.
     * @param path  The path to a file or the name of the key to save to.
     */
    public function save(path:String):Void
    {
        try
        {
#if html5
        js.Browser.getLocalStorage().setItem(path, toJson());
#else
        sys.io.File.saveContent(path, toJson());
#end
        }
        catch (e:Dynamic)
        {
            Log.error("Failed to save data to " + path);
        }
    }

    /**
     * Load a json string into the data store.
     * @param json  The json to load. Note that only the top level elements will be loaded.
     */
    public function fromJson(json:String):Void
    {
        var data = Json.parse(json);
        for (name in Reflect.fields(data))
        {
            store(name, Reflect.field(data, name));
        }
    }

    /**
     * Convert the data store to a json string.
     */
    public function toJson():String
    {
        return Json.stringify(_map);
    }

    /**
     * Retrieve a value from the data store.
     * @param name          The name of the value to return
     * @param defaultValue  The value to return if the data doesn't exist
     * @return The value for the name given, or the default value.
     */
    public function retrieve<T>(name:String, ?defaultValue:T):T
    {
        return _map.exists(name) ? cast _map.get(name) : defaultValue;
    }

    /**
     * Remove a value from the data store.
     * @param name  The name of the value to remove.
     */
    public function remove(name:String):Void
    {
        _map.remove(name);
    }

    /**
     * Stores a named value.
     * @param name       The name of the value to store.
     * @param value      The value to store.
     * @param overwrite  If true, it will overwrite the value if one exists. (default=true)
     */
    public function store(name:String, value:Dynamic, overwrite:Bool=true):Void
    {
        if (overwrite || !_map.exists(name))
        {
            _map.set(name, value);
        }
    }

    private var _map:StringMap<Dynamic>;

}
