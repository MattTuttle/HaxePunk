package haxepunk.backend.html5;

import js.lib.Promise;
import js.html.Audio;
import haxepunk.math.MathUtil;

class Sfx implements haxepunk.backend.generic.Sfx
{
	function new(audio:Audio)
	{
		this.audio = audio;
	}

	public static function loadFromURL(source:String):Promise<Sfx>
	{
		var audio = new Audio();
		var sfx = new Sfx(audio);
		return new Promise<Sfx>(function(resolve, reject) {
			audio.preload = 'auto';
			audio.src = source;
			audio.oncanplay = function() {
				resolve(sfx);
			}
		});
	}

	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	public var volume(get, set):Float;
	function get_volume():Float return audio.volume;
	function set_volume(value:Float):Float return audio.volume = MathUtil.clamp(value, 0, 1);

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false)
	{
		this.volume = volume;
		audio.loop = loop;
		audio.play();
	}

	public function resume()
	{
		audio.play();
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
		audio.pause();
		return audio.paused;
	}

	var audio:Audio;
}
