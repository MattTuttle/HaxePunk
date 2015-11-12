package haxepunk.debug;

import haxepunk.math.Vector3;
import haxepunk.scene.Scene;

interface Tool
{
	public function update(window:Window):Void;
	public function draw(cameraPosition:Vector3):Void;
}
