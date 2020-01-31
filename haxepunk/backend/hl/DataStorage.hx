package haxepunk.backend.hl;

import sys.io.File;

class DataStorage implements haxepunk.utils.DataStorage
{
	public function new() {}

	public function load(file:String):String
	{
		return File.getContent(file);
	}

	public function save(file:String, content:String):Void
	{
		File.saveContent(file, content);
	}
}
