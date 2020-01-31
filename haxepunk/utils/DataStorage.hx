package haxepunk.utils;

interface DataStorage
{
	public function load(file:String):String;
	public function save(file:String, data:String):Void;
}
