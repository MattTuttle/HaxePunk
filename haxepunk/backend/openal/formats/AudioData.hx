package haxepunk.backend.openal.formats;

import haxepunk.utils.Log;
import haxe.io.Bytes;
import openal.AL;

class AudioData
{
	public var sampleRate:Int;
	public var format:Int;

	public static function loadFromBytes(bytes:Bytes):Null<AudioData>
	{
		// read first two bytes in little-endian and compare to common image headers
		return switch (bytes.getUInt16(0))
		{
			case 0x4952: new Wav(bytes);
			case 0x674F: new Ogg(bytes);
			default: throw "Unsupported audio format";
		};
	}

	function getBufferFormat(channels:Int, bitsPerSample:Int):Int
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

		Log.critical("Unsupported buffer format (channels: " + channels + ", bits: " + bitsPerSample + ")");
		return 0;
	}

	public function fillBuffer(buffer:Bytes, length:Int):Int
	{
		throw "AudioData is the base class and should not be called directly";
	}
}
