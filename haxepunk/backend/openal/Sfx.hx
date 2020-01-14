package haxepunk.backend.openal;

import haxepunk.backend.generic.Sound;

class Sfx implements haxepunk.backend.generic.Sfx
{
	public function new(data:SoundSource)
	{
		this.data = data;
	}

	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	@:isVar public var volume(get, set):Float;
	function get_volume():Float return volume;
	function set_volume(value:Float):Float return volume = AudioEngine.setVolume(this, value);

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false)
	{
		this.volume = volume;
		AudioEngine.play(this, loop);
	}

	public function resume()
	{
		AudioEngine.resume(this);
	}

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	vol		Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(vol:Float = 1, pan:Float = 0)
	{
		play(vol, pan, true);
	}

	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool
	{
		return AudioEngine.stop(this);
	}

	var data:Sound;
}
