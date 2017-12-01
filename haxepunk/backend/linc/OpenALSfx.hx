package haxepunk.backend.linc;

#if linc_openal

import openal.AL.*;
import haxepunk.Signal;

class OpenALSfx implements haxepunk.Sfx
{

	public var onComplete = new Signal0();

	public function new(source:String)
	{

	}

	@:isVar public var volume(get, set):Float;
	inline function get_volume():Float return volume;
	inline function set_volume(value:Float):Float return volume = value;

	@:isVar public var pan(get, set):Float;
	inline function get_pan():Float return pan;
	inline function set_pan(value:Float):Float return pan = value;

	public function play(volume:Float = 1, pan:Float = 0)
	{

	}

	public function loop(volume:Float = 1, pan:Float = 0)
	{

	}

	public function stop():Bool
	{
		return false;
	}
}

#end
