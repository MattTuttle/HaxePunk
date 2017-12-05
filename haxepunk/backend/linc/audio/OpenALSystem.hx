package haxepunk.backend.linc.audio;

import haxepunk.audio.Sfx;
import haxepunk.math.MathUtil;

#if linc_openal

import openal.AL;

class OpenALSystem implements haxepunk.audio.AudioSystem
{
	var device:Device;

	public function new()
	{
		device = ALC.openDevice();
		var context = ALC.createContext(device);
		ALC.makeContextCurrent(context);
		AL.getError();
	}

	public function destroy()
	{
		var context = ALC.getCurrentContext();
		ALC.makeContextCurrent(null);
		ALC.destroyContext(context);
		ALC.closeDevice(device);
	}

	public function getSfx(name:String):Null<Sfx>
	{
		return new OpenALSfx(name);
	}

	public var volume(default, set):Float = 1;
	function set_volume(value:Float):Float
	{
		value = MathUtil.clamp(value, 0, 1);
		if (volume == value) return value;
		volume = value;
		// TODO: update all sounds
		return volume;
	}

	public var pan(default, set):Float = 0;
	function set_pan(value:Float):Float
	{
		value = MathUtil.clamp(value, -1, 1);
		if (pan == value) return value;
		pan = value;
		// TODO: update all sounds
		return pan;
	}
}

#end
