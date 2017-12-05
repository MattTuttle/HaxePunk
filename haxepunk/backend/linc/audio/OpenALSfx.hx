package haxepunk.backend.linc.audio;

#if linc_openal

import haxe.io.BytesData;
import openal.AL;
import haxepunk.Signal;

class OpenALSfx implements haxepunk.audio.Sfx
{

	public var onComplete = new Signal0();

	var source:Int;
	var buffer:Int;

	public function new(name:String)
	{
		var bytes = new BytesData();
		source = AL.genSource();
		buffer = AL.genBuffer();
		var frequency = 0;
		AL.bufferData(buffer, AL.FORMAT_STEREO16, frequency, bytes, 0, bytes.length);
		AL.sourcei(source, AL.BUFFER, buffer);
	}

	public function destroy()
	{
		AL.deleteSource(source);
		AL.deleteBuffer(buffer);
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
