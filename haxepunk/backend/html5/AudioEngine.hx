package haxepunk.backend.html5;

import haxepunk.math.MathUtil;

#if js

@:access(haxepunk.Sfx)
class AudioEngine implements haxepunk.audio.AudioEngine
{
	public function new()
	{

	}

	public function stop(sfx:Sfx):Bool
	{
		sfx.data.pause();
		return sfx.data.paused;
	}

	public function play(sfx:Sfx, loop:Bool=false):Bool
	{
		sfx.data.loop = loop;
		sfx.data.play();
		return true;
	}

	public function resume(sfx:Sfx):Bool
	{
		sfx.data.play();
		return true;
	}

	public function setVolume(sfx:Sfx, volume:Float):Float
	{
		return sfx.data.volume = MathUtil.clamp(volume, 0, 1);
	}

	public function update():Void
	{

	}

	public function quit():Void
	{

	}
}

#end
