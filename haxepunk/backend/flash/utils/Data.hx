package haxepunk.backend.flash.utils;

import haxe.ds.StringMap;
import flash.net.SharedObject;
import haxepunk.utils.DataProvider;

/**
 * Static helper class used for saving and loading data from stored cookies.
 */
class Data implements DataProvider
{
	public static var PREFIX:Null<String> = "HaxePunk";

	/**
	 * If you want to share data between different SWFs on the same host, use this id.
	 */
	public static var id:String = "";

	/**
	 * Overwrites the current data with the file.
	 * @param	file		The filename to load.
	 */
	public static function load(file:String = "")
	{
		var data:Dynamic = loadData(file);
		_data = new Map<String, Dynamic>();
		for (str in Reflect.fields(data)) _data.set(str, Reflect.field(data, str));
	}

	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 * @param	file		The filename to save.
	 * @param	overwrite	Clear the file before saving.
	 */
	public static function save(file:String = "", overwrite:Bool = true)
	{
		if (_shared != null) _shared.clear();
		var data:Dynamic = loadData(file);
		var str:String;
		if (overwrite)
			for (str in Reflect.fields(data)) Reflect.deleteField(data, str);
		for (str in _data.keys()) Reflect.setField(data, str, _data.get(str));

#if js
		_shared.flush();
#else
		_shared.flush(SIZE);
#end
	}

	/**
	 * Reads a property from the data object.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function read(name:String, ?defaultValue:String):String
	{
		if (_data.has(name)) return _data.get(name);
		return defaultValue;
	}

	/**
	 * Writes a Dynamic object to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function write(name:String, value:String)
	{
		_data.set(name, value);
	}

	/** @private Loads the data file, or return it if you're loading the same one. */
	static function loadData(file:String):Dynamic
	{
		if (file == null) file = DEFAULT_FILE;
		var p = (PREFIX == null ? "" : PREFIX + "/");
		if (id != "") _shared = SharedObject.getLocal('$p$id/$file', "/");
		else _shared = SharedObject.getLocal('$p$file');
		return _shared.data;
	}

	// Data information.
	static var _shared:SharedObject;
	static var _dir:String;
	static var _data:StringMap<String> = new StringMap<String>();
	static inline var DEFAULT_FILE:String = "_file";
	static inline var SIZE:Int = 10000;
}
