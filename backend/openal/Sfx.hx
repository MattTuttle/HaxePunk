package backend.openal;

import backend.openal.formats.*;
import haxepunk.math.MathUtil;
import haxe.io.Bytes;
import openal.AL;

class Sfx implements backend.generic.Sfx
{
	public function new(data:AudioData)
	{
		this.data = data;
		AudioEngine.addSfx(this);
	}

	function clear()
	{
		stop();
		AudioEngine.emptySource(source);
		buffers = [];
		data = null;
	}

	public static function loadFromBytes(bytes:Bytes):Null<Sfx>
	{
		// read first two bytes in little-endian and compare to common image headers
		return new Sfx(switch (bytes.getUInt16(0))
		{
			case 0x4952: new Wav(bytes);
			case 0x674F: new Ogg(bytes);
			default: throw "Unsupported audio format";
		});
	}

	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	@:isVar public var volume(get, set):Float;
	function get_volume():Float return volume;
	function set_volume(value:Float):Float
	{
		MathUtil.clamp(value, 0, 1);
		AL.sourcef(source, AL.GAIN, volume);
		return volume;
	}

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false)
	{
		AL.sourcei(source, AL.LOOPING, loop ? AL.TRUE : AL.FALSE);
		AL.sourcePlay(source);
	}

	public function resume()
	{
		AL.sourcePlay(source);
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
		AL.sourceStop(source);
		return true;
	}

	var source:Source;
	var buffers = new Array<Buffer>();
	var data:AudioData;
}
