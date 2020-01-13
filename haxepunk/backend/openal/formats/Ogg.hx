package haxepunk.backend.openal.formats;

#if hl
import haxe.io.Bytes;

private typedef OggFile = hl.Abstract<"fmt_ogg">;

class Ogg extends AudioData
{
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
		trace(bitrate, samples, frequency, channels);
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
