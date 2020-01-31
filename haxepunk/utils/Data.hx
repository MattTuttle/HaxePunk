package haxepunk.utils;

import haxe.Unserializer;
import haxe.Serializer;
import haxe.ds.StringMap;

#if (lime || nme)

typedef Data = haxepunk.backend.flash.utils.Data;

#else

#if hl

typedef DataStorageNative = haxepunk.backend.hl.DataStorage;

#elseif js

typedef DataStorageNative = haxepunk.backend.html5.DataStorage;

#else

#error "Data storage class not defined"

#end

/**
 * Static helper class used for saving and loading data from stored cookies.
 */
class Data
{
	public static final PREFIX:String = "HaxePunk";

	/**
	 * If you want to share data on the same host, use this id.
	 */
	public static var id:String = "";

	static var storage = new DataStorageNative();

	static function resolveName(file:String)
	{
		if (file == null) file = DEFAULT_FILE;
		var pre = (PREFIX == null ? "" : PREFIX + "-");
		return id == "" ? '$pre$file' : '$pre$id-$file';
	}

	/**
	 * Overwrites the current data with the file.
	 * @param	file		The filename to load.
	 */
	public static inline function load(?file:String):Void
	{
		file = resolveName(file);
		try {
			data = Unserializer.run(storage.load(file));
		} catch (e:Dynamic) {
			Log.critical("Could not load data for " + file);
		}
	}

	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 * @param	file		The filename to save.
	 */
	public static function save(?file:String):Void
	{
		file = resolveName(file);
		try {
			storage.save(file, Serializer.run(data));
		} catch (e:Dynamic) {
			Log.critical("Could not load data for " + file);
		}
	}

	/**
	 * Reads an int from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readInt(name:String, defaultValue:Int = 0):Int
	{
		return read(name, defaultValue);
	}

	/**
	 * Reads a Boolean from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readBool(name:String, defaultValue:Bool = true):Bool
	{
		return read(name, defaultValue);
	}

	/**
	 * Reads a String from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readString(name:String, defaultValue:String = ""):String
	{
		return read(name, defaultValue);
	}

	/**
	 * Reads a property from the data object.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	@:generic public static function read<T>(name:String, ?defaultValue:T):T
	{
		var value:T;
		try {
			value = Unserializer.run(data.get(name));
			if (value == null) value = defaultValue;
		} catch(e:Dynamic) {
			value = defaultValue;
		}
		return value;
	}

	/**
	 * Writes a Dynamic object to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function write(name:String, value:Dynamic):Void
	{
		data.set(name, Serializer.run(value));
	}

	static var data:StringMap<String>;
	static var DEFAULT_FILE:String = "_file";
}

#end
