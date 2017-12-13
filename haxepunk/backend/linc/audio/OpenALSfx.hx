package haxepunk.backend.linc.audio;

#if linc_openal

import haxe.io.BytesData;
import openal.AL;
import haxepunk.Signal;
import haxepunk.audio.Wave;

class OpenALSfx implements haxepunk.audio.Sfx
{

	public var onComplete = new Signal0();

	var source:Int;
	var buffer:Int;

	public function new(name:String)
	{
		var bytes = HXP.app.assets.getBytes(name);
		var audio = Wave.fromBytes(bytes);
		if (audio != null)
		{
			source = AL.genSource();
			buffer = AL.genBuffer();
			var format = switch (audio.channels)
			{
				case 1: audio.bitsPerSample == 16 ? AL.FORMAT_MONO16 : AL.FORMAT_MONO8;
				case 2: audio.bitsPerSample == 16 ? AL.FORMAT_STEREO16 : AL.FORMAT_STEREO8;
				default: throw 'Unsupported audio bitrate (${audio.bitsPerSample}) and channels (${audio.channels})';
			}
			AL.bufferData(buffer, format, audio.frequency, audio.data, 0, audio.data.length);
			AL.sourcei(source, AL.BUFFER, buffer);
		}
	}

	public function destroy()
	{
		AL.deleteSource(source);
		AL.deleteBuffer(buffer);
	}

	@:isVar public var volume(get, set):Float;
	inline function get_volume():Float return volume;
	inline function set_volume(value:Float):Float return volume = value;

	@:isVar public var pan(get, set):Float;
	inline function get_pan():Float return pan;
	inline function set_pan(value:Float):Float return pan = value;

	public function play(volume:Float = 1, pan:Float = 0)
	{
		AL.sourcePlay(source);
	}

	public function loop(volume:Float = 1, pan:Float = 0)
	{

	}

	public function stop():Bool
	{
		return false;
	}
}

#end
