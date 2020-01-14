package haxepunk.backend.openal.formats;

#if hl
import haxe.io.Bytes;

private typedef OggFile = hl.Abstract<"fmt_ogg">;

class Ogg extends AudioData
{

	static var OGGFMT_I8:Int = 1;
	static var OGGFMT_I16:Int = 2;

	static var OGGFMT_BIGENDIAN:Int = 128;
	static var OGGFMT_UNSIGNED:Int = 256;

	var bytes:Bytes;
	var reader:OggFile;
	var currentSample:Int;

	public function new(bytes:Bytes)
	{
		this.bytes = bytes;
		reader = ogg_open(bytes, bytes.length);
		if( reader == null ) throw "Failed to decode OGG data";

		var bitrate = 0, frequency = 0, samples = 0, channels = 0;
		ogg_info(reader, bitrate, frequency, samples, channels);
		sampleRate = frequency;
		format = getBufferFormat(channels, 16);
	}

	override public function fillBuffer(buffer:Bytes, start:Int, length:Int):Int
	{
		var sampleStart = Std.int(start / 4);
		if (!ogg_seek(reader, sampleStart))
		{
			Log.critical("Invalid sample start!");
			return 0;
		}
		var bytes = hl.Bytes.fromBytes(buffer);
		var bytesNeeded = length;
		while (bytesNeeded > 0)
		{
			var read = ogg_read(reader, bytes, bytesNeeded, OGGFMT_I16);
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
