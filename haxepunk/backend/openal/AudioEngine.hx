package haxepunk.backend.openal;

#if hlopenal

import haxe.CallStack;
import haxepunk.backend.openal.formats.AudioData;
import haxepunk.math.MathUtil;
import openal.ALC;
import openal.AL;
import openal.EFX;

enum PlaybackState {
	Created;
	Stopped;
	Playing;
	Paused;
}

typedef AudioHandle = {
	sfx:Sfx,
	position:Int,
	loop: Bool,
	state:PlaybackState,
	buffers:Array<Buffer>,
	source:Source,
};

class AudioEngine implements haxepunk.audio.AudioEngine
{
	final BUFFER_SIZE:Int = 4096*8;
	final NUM_BUFFERS:Int = 2;

	function removeHandle(handle:AudioHandle):Void
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

	@:access(haxepunk.Sfx)
	function stream(buffer:Buffer, handle:AudioHandle):Bool
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

	function createSource(sfx:Sfx):AudioHandle
	{
		AL.genSources(1, tmpBytes);
		var source = Source.ofInt(tmpBytes.getI32(0));

		var handle = {
			sfx: sfx,
			loop: false,
			state: Created,
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

	function getHandle(sfx:Sfx):AudioHandle
	{
		var handle = handleBySfx.get(sfx);
		if (handle == null) {
			handle = createSource(sfx);
		}
		return handle;
	}

	public function stop(sfx:Sfx):Bool
	{
		var handle = getHandle(sfx);
		AL.sourceStop(handle.source);
		handle.state = Stopped;
		return true;
	}

	public function play(sfx:Sfx, loop:Bool=false):Bool
	{
		var handle = getHandle(sfx);
		AL.sourcePlay(handle.source);
		handle.state = Playing;
		// TODO: handle looping with buffers
		handle.loop = loop;
		return true;
	}

	public function resume(sfx:Sfx):Bool
	{
		return play(sfx, getHandle(sfx).loop);
	}

	public function setVolume(sfx:Sfx, volume:Float):Float
	{
		var handle = getHandle(sfx);
		volume = MathUtil.clamp(volume, 0, 1);
		AL.sourcef(handle.source, AL.GAIN, volume);
		return volume;
	}

	function checkError()
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

	public function update()
	{
		var toRemove = [];
		for (handle in handles)
		{
			var source = handle.source;
			
			// sounds will stop when window is moved, this checks the handle state vs openal's state and makes sure they are in sync
			var state = AL.getSourcei(source, AL.SOURCE_STATE);
			if (state == AL.STOPPED && handle.state == Playing)
			{
				AL.sourcePlay(source);
			}

			var processed = AL.getSourcei(source, AL.BUFFERS_PROCESSED);
			while (processed > 0)
			{
				var gain = AL.getSourcei(source, AL.GAIN);
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
				processed -= 1;
			}
		}
		for (handle in toRemove)
		{
			removeHandle(handle);
		}
	}

	public function new()
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

	public function quit()
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

	var tmpBytes:hl.Bytes;
	var maxAuxiliarySends:Int;
	var handles = new Array<AudioHandle>();
	var handleBySfx = new Map<Sfx, AudioHandle>();
}

#end
