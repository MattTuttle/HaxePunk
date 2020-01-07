package backend.openal;

import haxe.CallStack;
#if hlopenal

import backend.openal.formats.AudioData;
import haxepunk.math.MathUtil;
import openal.ALC;
import openal.AL;
import openal.EFX;

class AudioEngine
{
	static final BUFFER_SIZE:Int = 4096*8;
	static final NUM_BUFFERS:Int = 2;

	public static function emptySource(source:Source):Void
	{
		var buffers = AL.getSourcei(source, AL.BUFFERS_QUEUED);
		AL.sourceUnqueueBuffers(source, buffers, tmpBytes);
		checkError();
	}

	static function stream(buffer:Buffer, data:AudioData):Bool
	{
		// TODO: check if this needs to be re-allocated every time we stream
		var bytes = haxe.io.Bytes.alloc(BUFFER_SIZE);
		var size = data.fillBuffer(bytes, BUFFER_SIZE);
		if (size > 0)
		{
			AL.bufferData(buffer, data.format, bytes, size, data.sampleRate);
			checkError();
			return true;
		}
		else
		{
			return false;
		}
	}

	@:access(backend.openal.Sfx)
	public static function addSfx(sfx:Sfx)
	{
		AL.genSources(1, tmpBytes);
		var source = Source.ofInt(tmpBytes.getI32(0));
		// create several audio buffers and fill them with data
		for (i in 0...NUM_BUFFERS)
		{
			AL.genBuffers(1, tmpBytes);
			var buffer = Buffer.ofInt(tmpBytes.getI32(0));
			stream(buffer, sfx.data);
			tmpBytes.setI32(i*4, buffer.toInt());
			sfx.buffers.push(buffer);
		}
		// attach the audio buffers to the source
		AL.sourceQueueBuffers(source, NUM_BUFFERS, tmpBytes);
		checkError();
		sfx.source = source;
		sounds.push(sfx);
	}

	static function checkError()
	{
		var error = AL.getError();
		if (error != AL.NO_ERROR) {
			for (i in CallStack.callStack())
			{
				trace(i);
			}
			trace("AL Error: " + error);
		}
	}

	@:access(backend.openal.Sfx)
	public static function update()
	{
		var removeSfx = [];
		for (sfx in sounds)
		{
			var source = sfx.source;
			var processed = AL.getSourcei(source, AL.BUFFERS_PROCESSED);
			for (_ in 0...processed)
			{
				var buffer = sfx.buffers.shift();
				trace(buffer);
				tmpBytes.setI32(0, buffer.toInt());
				AL.sourceUnqueueBuffers(source, 1, tmpBytes);
				checkError();
				if (stream(buffer, sfx.data))
				{
					AL.sourceQueueBuffers(source, 1, tmpBytes);
					sfx.buffers.push(buffer);
					checkError();
				}
				else
				{
					// sfx is finish, remove it
					removeSfx.push(sfx);
					trace("remove");
				}
			}
		}
		for (sfx in removeSfx)
		{
			sounds.remove(sfx);
		}
	}

	public static function initOpenAL()
	{
		tmpBytes = new hl.Bytes(64);

		var device = ALC.openDevice(null);
		var context = ALC.createContext(device, null);

		ALC.makeContextCurrent(context);
		ALC.loadExtensions(device);
		AL.loadExtensions();

		ALC.getIntegerv(device, EFX.MAX_AUXILIARY_SENDS, 1, tmpBytes);
		maxAuxiliarySends = tmpBytes.getI32(0);

		if (AL.getError() != AL.NO_ERROR)
		{
			throw "could not init openAL Driver";
		}
	}

	public static function quit()
	{
		var context = ALC.getCurrentContext();
		var device = ALC.getContextsDevice(context);
		ALC.makeContextCurrent(null);
		ALC.destroyContext(context);
		ALC.closeDevice(device);
	}

	public var masterVolume(default, set):Float;
	function set_masterVolume(volume:Float):Float
	{
		volume = MathUtil.clamp(volume, 0, 1);
		AL.listenerf(AL.GAIN, volume);
		return masterVolume = volume;
	}

	static var tmpBytes:hl.Bytes;
	static var maxAuxiliarySends:Int;
	static var sounds = new Array<Sfx>();
}

#end
