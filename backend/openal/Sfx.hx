package backend.openal;

import haxe.io.BytesInput;
import haxepunk.math.MathUtil;
import haxe.io.Bytes;
import openal.AL;

class Sfx implements backend.generic.Sfx
{
	public function new(bytes:hl.Bytes, length:Int, sampleRate:Int, format:Int)
	{
		var buffer = AudioEngine.createBuffer(bytes, length, sampleRate, format);
		source = AudioEngine.createSource();
		AL.sourcei(source, AL.BUFFER, buffer.toInt());
	}

	public static function loadFromBytes(bytes:Bytes):Null<Sfx>
	{
		// read first two bytes in little-endian and compare to common image headers
		return switch (bytes.getUInt16(0))
		{
			case 0x4952: decodeWAV(bytes);
			default: throw "Unsupported audio format";
		}
	}

	static function decodeWAV(bytes:Bytes):Null<Sfx>
	{
		var input = new BytesInput(bytes);
		input.bigEndian = false;

		if (input.readString(4) != 'RIFF') return null;
		var filesize = input.readInt32();
		if (input.readString(4) != 'WAVE') return null;

		// read header
		if (input.readString(4) != 'fmt ') return null;
		var headerSize = input.readInt32();
		if (input.readUInt16() != 1)
		{
			throw "WAV PCM is the only supported format";
		}
		var channels = input.readUInt16();
		var sampleRate = input.readInt32();
		input.readInt32(); // bytes per second
		input.readUInt16(); // block align
		var bitsPerSample = input.readUInt16();
		input.position += headerSize - 16; // ignore any other header details

		// read start of data section
		if (input.readString(4) != 'data') return null;
		var length = filesize - input.position;

		var format = getBufferFormat(channels, bitsPerSample);

		var data = new hl.Bytes(length);
		data.blit(0, bytes, input.position, length);
		return new Sfx(data, length, sampleRate, format);
	}

	static function getBufferFormat(channels:Int, bitsPerSample:Int):Int
	{
		if (bitsPerSample == 8)
		{
			if (channels == 1) return AL.FORMAT_MONO8;
			if (channels == 2) return AL.FORMAT_STEREO8;
		}
		if (bitsPerSample == 16)
		{
			if (channels == 1) return AL.FORMAT_MONO16;
			if (channels == 2) return AL.FORMAT_STEREO16;
		}
		throw "Unsupported buffer format (channels: " + channels + ", bits: " + bitsPerSample + ")";
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
}
