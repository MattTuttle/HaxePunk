package backend.openal;

#if hlopenal

import haxepunk.math.MathUtil;
import haxe.io.Bytes;
import openal.ALC;
import openal.AL;
import openal.EFX;

class AudioEngine
{
	public static function createBuffer(bytes:hl.Bytes, length:Int, sampleRate:Int, format:Int):Buffer
	{
		AL.genBuffers(1, tmpBytes);
		var buffer = Buffer.ofInt(tmpBytes.getI32(0));

		AL.bufferData(buffer, format, bytes, length, sampleRate);
		var error = AL.getError();
		if (error != AL.NO_ERROR) {
			trace("AL Error: " + error);
			AL.deleteBuffers(1, tmpBytes);
		}
		return buffer;
	}

	public static function createSource():Source
	{
		AL.genSources(1, tmpBytes);
		return Source.ofInt(tmpBytes.getI32(0));
	}

	public static function initOpenAL()
	{
		tmpBytes = new hl.Bytes(16);

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
}

#end
