package haxepunk.backend.openal;

#if hlopenal

import haxe.CallStack;
import haxepunk.backend.openal.formats.AudioData;
import haxepunk.math.MathUtil;
import openal.ALC;
import openal.AL;
import openal.EFX;

typedef AudioHandle = {
	sfx:Sfx,
	position:Int,
	buffers:Array<Buffer>,
	source:Source,
};

class AudioEngine
{
	static final BUFFER_SIZE:Int = 4096*8;
	static final NUM_BUFFERS:Int = 2;

	static function removeHandle(handle:AudioHandle):Void
	{
		if (handle.sfx == null) return;

		Log.debug("Removing audio handle");

		var buffers = AL.getSourcei(handle.source, AL.BUFFERS_QUEUED);
		AL.sourceUnqueueBuffers(handle.source, buffers, tmpBytes);
		checkError();

		tmpBytes.setI32(0, handle.source.toInt());
		AL.deleteSources(1, tmpBytes);
		checkError();

		handles.remove(handle);
		handleBySfx.remove(handle.sfx);

		// prevent this handle from unloading multiple times
		handle.sfx = null;
		handle.position = 0;
	}

	@:access(haxepunk.backend.openal.Sfx)
	static function stream(buffer:Buffer, handle:AudioHandle):Bool
	{
		var data = handle.sfx.data;
		// TODO: check if this needs to be re-allocated every time we stream
		var bytes = haxe.io.Bytes.alloc(BUFFER_SIZE);
		var size = data.fillBuffer(bytes, handle.position, BUFFER_SIZE);
		if (size > 0)
		{
			handle.position += size;
			AL.bufferData(buffer, data.format, bytes, size, data.sampleRate);
			checkError();
			return true;
		}
		else
		{
			return false;
		}
	}

	static function createSource(sfx:Sfx):AudioHandle
	{
		AL.genSources(1, tmpBytes);
		var source = Source.ofInt(tmpBytes.getI32(0));

		var handle = {
			sfx: sfx,
			position: 0,
			source: source,
			buffers: new Array<Buffer>()
		};

		// create several audio buffers and fill them with data
		AL.genBuffers(NUM_BUFFERS, tmpBytes);
		checkError();
		for (i in 0...NUM_BUFFERS)
		{
			var buffer = Buffer.ofInt(tmpBytes.getI32(i*4));
			stream(buffer, handle);
			handle.buffers.push(buffer);
		}
		AL.sourceQueueBuffers(source, NUM_BUFFERS, tmpBytes);
		checkError();

		handles.push(handle);
		handleBySfx.set(sfx, handle);
		return handle;
	}

	static function getHandle(sfx:Sfx):AudioHandle
	{
		var handle = handleBySfx.get(sfx);
		if (handle == null) {
			handle = createSource(sfx);
		}
		return handle;
	}

	public static function stop(sfx:Sfx)
	{
		var handle = getHandle(sfx);
		AL.sourceStop(handle.source);
		return true;
	}

	public static function play(sfx:Sfx, loop:Bool=false)
	{
		var handle = getHandle(sfx);
		AL.sourcei(handle.source, AL.LOOPING, loop ? AL.TRUE : AL.FALSE);
		AL.sourcePlay(handle.source);
		return true;
	}

	public static function resume(sfx:Sfx)
	{
		var handle = getHandle(sfx);
		AL.sourcePlay(handle.source);
		return true;
	}

	public static function setVolume(sfx:Sfx, volume:Float):Float
	{
		var handle = getHandle(sfx);
		volume = MathUtil.clamp(volume, 0, 1);
		AL.sourcef(handle.source, AL.GAIN, volume);
		return volume;
	}

	static function checkError()
	{
		#if hxp_debug
		var error = AL.getError();
		if (error != AL.NO_ERROR) {
			Log.critical("AL Error: " + switch(error) {
				case AL.INVALID_OPERATION: "Invalid Operation";
				case AL.INVALID_NAME: "Invalid Name";
				case AL.INVALID_ENUM: "Invalid Enum";
				case AL.INVALID_VALUE: "Invalid Value";
				case AL.OUT_OF_MEMORY: "Out of Memory";
				default: "Unknown Error";
			});
			Log.critical(CallStack.toString(CallStack.callStack()));
		}
		#end
	}

	public static function update()
	{
		var toRemove = [];
		for (handle in handles)
		{
			var source = handle.source;
			var processed = AL.getSourcei(source, AL.BUFFERS_PROCESSED);
			for (_ in 0...processed)
			{
				// unqueue the buffer
				var buffer = handle.buffers.shift();
				tmpBytes.setI32(0, buffer.toInt());
				AL.sourceUnqueueBuffers(source, 1, tmpBytes);
				checkError();

				if (stream(buffer, handle))
				{
					AL.sourceQueueBuffers(source, 1, tmpBytes);
					handle.buffers.push(buffer);
					checkError();
				}
				else if (handle.buffers.length == 0)
				{
					// remove the handle when all buffers are exhausted
					toRemove.push(handle);
				}
			}
		}
		for (handle in toRemove)
		{
			removeHandle(handle);
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
	static var handles = new Array<AudioHandle>();
	static var handleBySfx = new Map<Sfx, AudioHandle>();
}

#end
