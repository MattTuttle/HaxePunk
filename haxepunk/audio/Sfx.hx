package haxepunk.audio;

import haxepunk.Signal;

interface Sfx
{
	/**
	 * Optional callback function for when the sound finishes playing.
	 */
	public var onComplete:Signal0;

	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	public var volume(get, set):Float;

	/**
	 * Alter the panning factor (a value from -1 to 1) of the sound during playback.
	 * Panning only applies to mono sounds. It is ignored on stereo.
	 */
	public var pan(get, set):Float;

	/**
	 * Plays the sound once.
	 * @param	volume Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0):Void;

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	volume	Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(volume:Float = 1, pan:Float = 0):Void;

	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool;
}
