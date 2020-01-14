package haxepunk.backend.openal.formats;

#if hl
import haxe.io.Bytes;

private typedef OggFile = hl.Abstract<"fmt_ogg">;

class Ogg extends AudioData
{
	var bytes:Bytes;
	var reader:OggFile;
	var currentSample:Int;
	var channels:Int;
	var bytesPerSample:Int = 2; // default to 16 bits

	public function new(bytes:Bytes)
	{
		this.bytes = bytes;
		reader = ogg_open(bytes, bytes.length);
		if( reader == null ) throw "Failed to decode OGG data";

		// must use local variables
		var bitrate = 0, samples = 0, frequency = 0, channels = 0;
		ogg_info(reader, bitrate, frequency, samples, channels);
		format = getBufferFormat(channels, bytesPerSample * 8);
		sampleRate = frequency;
		this.channels = channels;
	}

	override public function fillBuffer(buffer:Bytes, start:Int, length:Int):Int
	{
		var sampleStart = Std.int(start / (bytesPerSample * channels));
		if (!ogg_seek(reader, sampleStart))
		{
			Log.critical("Invalid sample start!");
			return 0;
		}
		var bytes = hl.Bytes.fromBytes(buffer);
		var bytesNeeded = length;
		while (bytesNeeded > 0)
		{
			var read = ogg_read(reader, bytes, bytesNeeded, bytesPerSample);
			if (read < 0)
			{
				Log.critical("Failed to decode OGG data");
				return 0;
			}
			// EOF
			if (read == 0) break;
			bytesNeeded -= read;
			bytes = bytes.offset(read);
		}
		return length - bytesNeeded;
	}

	@:hlNative("fmt", "ogg_open")
	static function ogg_open(bytes:hl.Bytes, size:Int):OggFile {
		return null;
	}

	@:hlNative("fmt", "ogg_seek")
	static function ogg_seek(o:OggFile, sample:Int):Bool {
		return false;
	}

	@:hlNative("fmt", "ogg_info")
	static function ogg_info(o:OggFile, bitrate:hl.Ref<Int>, freq:hl.Ref<Int>, samples:hl.Ref<Int>, channels:hl.Ref<Int> ):Void {}

	@:hlNative("fmt", "ogg_read")
	static function ogg_read(o:OggFile, output:hl.Bytes, size:Int, format:Int ):Int {
		return 0;
	}
}

#end
