package backend.openal;

import haxepunk.math.MathUtil;
import haxe.io.Bytes;
import openal.ALC;
import openal.AL;
import openal.EFX;

class AudioEngine
{
	public function new()
	{
		var device = ALC.openDevice(null);
		var context = ALC.createContext(device, null);

		ALC.makeContextCurrent(context);
		ALC.loadExtensions(device);
		AL.loadExtensions();

		var bytes = Bytes.alloc(4);
		ALC.getIntegerv(device, EFX.MAX_AUXILIARY_SENDS, 1, bytes);
		var maxAuxiliarySends = bytes.getInt32(0);
		trace(maxAuxiliarySends);

		if (AL.getError() != AL.NO_ERROR)
		{
			throw "could not init openAL Driver";
		}
	}

	public var masterVolume(default, set):Float;
	function set_masterVolume(volume:Float):Float
	{
		volume = MathUtil.clamp(volume, 0, 1);
		AL.listenerf(AL.GAIN, volume);
		return masterVolume = volume;
	}
}
