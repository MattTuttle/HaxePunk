package haxepunk.backend.html5;

import js.html.Storage;

class DataStorage implements haxepunk.utils.DataStorage
{
	var storage:Storage;

	public function new()
	{
		storage = js.Browser.getLocalStorage();
	}

	public function load(file:String):String
	{
		return storage.getItem(file);
	}

	public function save(file:String, value:String):Void
	{
		storage.setItem(file, value);
	}
}
