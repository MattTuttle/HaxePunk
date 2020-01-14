package haxepunk.audio;

import haxepunk.Sfx;

interface AudioEngine
{
	public function stop(sfx:Sfx):Bool;
	public function play(sfx:Sfx, loop:Bool=false):Bool;
	public function resume(sfx:Sfx):Bool;
	public function setVolume(sfx:Sfx, volume:Float):Float;

	public function update():Void;
	public function quit():Void;
}
