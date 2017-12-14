package haxepunk.backend.linc.audio;

#if linc_openal

import haxepunk.audio.Sfx;
import haxepunk.math.MathUtil;
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
		OpenALBuffer.destroyAll();
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
		AL.listenerf(AL.GAIN, value);
		return volume = value;
	}

	public var pan(default, set):Float = 0;
	function set_pan(value:Float):Float
	{
		value = MathUtil.clamp(value, -1, 1);
		AL.listener3f(AL.POSITION, value, 0, 0);
		return pan;
	}
}

#end
