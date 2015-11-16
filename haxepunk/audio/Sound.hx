package haxepunk.audio;

import lime.Assets;
import lime.audio.*;
import haxepunk.math.*;

class Sound
{

	public function new(path:String)
	{
		_sound = Assets.getAudioBuffer(path);
		_source = new AudioSource(_sound);
	}

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   Number of times to loop the audio
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false):Void
	{
		_source.gain = volume;
		// _source.pan = pan;
		// TODO: figure out how to properly do infinite loop
		_source.loops = loop ? Math.INT_MAX : 0;
		_source.play();
	}

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	volume	Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(volume:Float = 1, pan:Float = 0):Void
	{
		play(volume, pan, true);
	}

	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool
	{
		var playing = isPlaying;
		if (playing) _source.stop();
		return playing;
	}

	/**
	 * Resumes the sound from the position stop() was called on it.
	 */
	public function resume():Void
	{
	}

	/**
	 * If the sound is currently playing.
	 */
	public var isPlaying(get, never):Bool;
	@:access(lime.audio.AudioSource)
	private inline function get_isPlaying():Bool { return _source.playing; }

	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(get, never):Float;
	private inline function get_position():Float { return _source.currentTime; }

	private var _sound:AudioBuffer;
	private var _source:AudioSource;

}
