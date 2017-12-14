package haxepunk.backend.linc.audio;

#if linc_openal

import haxe.ds.StringMap;
import haxe.io.BytesData;
import openal.AL;
import haxepunk.audio.Wave;

class OpenALBuffer
{
	/**
	 * Length of the buffer in seconds
	 */
	public var length(default, null):Float;

	var buffer:ALuint;

	function new()
	{
		buffer = AL.genBuffer();
	}

	public static function load(name:String):OpenALBuffer
	{
		var buffer:OpenALBuffer;
		if (buffers.exists(name))
		{
			buffer = buffers.get(name);
		}
		else
		{
			buffer = new OpenALBuffer();
			buffers.set(name, buffer);

			var bytes = HXP.app.assets.getBytes(name);
			var audio = Wave.fromBytes(bytes);
			buffer.loadAudio(audio);
		}
		return buffer;
	}

	public function assignSource(source:ALuint)
	{
		AL.sourcei(source, AL.BUFFER, buffer);
	}

	function loadAudio(audio:Wave)
	{
		length = audio.data.length / (audio.channels * (audio.bitsPerSample / 8) * audio.frequency);
		var format = switch (audio.channels)
		{
			case 1: audio.bitsPerSample == 16 ? AL.FORMAT_MONO16 : AL.FORMAT_MONO8;
			case 2: audio.bitsPerSample == 16 ? AL.FORMAT_STEREO16 : AL.FORMAT_STEREO8;
			default: throw 'Unsupported audio bitrate (${audio.bitsPerSample}) and channels (${audio.channels})';
		}
		AL.bufferData(buffer, format, audio.frequency, audio.data, 0, audio.data.length);
	}

	public function destroy()
	{
		AL.deleteBuffer(buffer);
	}

	public static function destroyAll()
	{
		for (buffer in buffers)
		{
			buffer.destroy();
		}
	}

	static var buffers = new StringMap<OpenALBuffer>();
}

#end
