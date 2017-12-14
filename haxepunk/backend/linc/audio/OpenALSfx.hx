package haxepunk.backend.linc.audio;

#if linc_openal

import openal.AL;
import haxepunk.Signal;

class OpenALSfx implements haxepunk.audio.Sfx
{

	public var onComplete = new Signal0();

	var source:Int;
	var buffer:OpenALBuffer;

	/**
	 * If the sound is currently playing.
	 */
	public var isPlaying(get, never):Bool;
	inline function get_isPlaying():Bool return AL.getSourcei(source, AL.SOURCE_STATE) == AL.PLAYING;

	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(get, set):Float;
	inline function get_position():Float return AL.getSourcef(source, AL.SEC_OFFSET);
	inline function set_position(value:Float):Float
	{
		AL.sourcef(source, AL.SEC_OFFSET, value);
		return value;
	}

	/**
	 * Length of the sound, in seconds.
	 */
	public var length(get, never):Float;
	inline function get_length():Float return buffer.length;

	public function new(name:String)
	{
		buffer = OpenALBuffer.load(name);
		source = AL.genSource();
		buffer.assignSource(source);
	}

	public function destroy()
	{
		AL.deleteSource(source);
	}

	@:isVar public var volume(get, set):Float;
	inline function get_volume():Float return volume;
	inline function set_volume(value:Float):Float
	{
		AL.sourcef(source, AL.GAIN, value);
		return volume = value;
	}

	@:isVar public var pan(get, set):Float;
	inline function get_pan():Float return pan;
	inline function set_pan(value:Float):Float
	{
		AL.source3f(source, AL.POSITION, value, 0, 0);
		return pan = value;
	}

	public function play(volume:Float = 1, pan:Float = 0)
	{
		this.volume = volume;
		this.pan = pan;
		AL.sourcePlay(source);
	}

	public function loop(volume:Float = 1, pan:Float = 0)
	{
		AL.sourcei(source, AL.LOOPING, AL.TRUE);
		play(volume, pan);
	}

	public function stop():Bool
	{
		AL.sourceStop(source);
		return true;
	}
}

#end
