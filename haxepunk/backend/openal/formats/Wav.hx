package haxepunk.backend.openal.formats;

import haxepunk.utils.Log;
import haxe.io.BytesInput;
import haxe.io.Bytes;

class Wav extends AudioData
{
	public function new(bytes:Bytes)
	{
		data = bytes;
		decode(bytes);
	}

	function decode(bytes:Bytes):Bool
	{
		var input = new BytesInput(bytes);
		input.bigEndian = false;

		if (input.readString(4) != 'RIFF') return false;
		var filesize = input.readInt32();
		if (input.readString(4) != 'WAVE') return false;

		// read header
		if (input.readString(4) != 'fmt ') return false;
		var headerSize = input.readInt32();
		if (input.readUInt16() != 1)
		{
			Log.critical("WAV PCM is the only supported format");
			return false;
		}
		var channels = input.readUInt16();
		sampleRate = input.readInt32();
		input.readInt32(); // bytes per second
		input.readUInt16(); // block align
		var bitsPerSample = input.readUInt16();
		input.position += headerSize - 16; // ignore any other header details

		// read start of data section
		if (input.readString(4) != 'data') return false;
		var length = filesize - input.position;
		dataStart = input.position;

		format = getBufferFormat(channels, bitsPerSample);
		return true;
	}

	override public function fillBuffer(buffer:Bytes, position:Int, length:Int):Int
	{
		var start = dataStart + position;
		if (start + length > data.length)
		{
			length = data.length - start;
		}
		buffer.blit(0, data, start, length);
		return length;
	}

	var data:Bytes;
	var dataStart:Int;
}
