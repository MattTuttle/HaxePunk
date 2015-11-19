package haxepunk.debug;

import haxepunk.Window;
import haxepunk.inputs.*;
import haxepunk.math.*;

class CameraTool implements Tool
{

	public function new() { }

	public function update(window:Window)
	{
		var camera = window.scene.camera;
		if (lastPos != null)
		{
			camera.position += lastPos - camera.screenToCamera(window.input.mouse.position);
		}

		// rotate
		if (window.input.check(Key.RIGHT))
		{
			camera.angle += Math.RAD;
		}
		if (window.input.check(Key.LEFT))
		{
			camera.angle -= Math.RAD;
		}

		// zoom
		if (window.input.check(Key.UP))
		{
			camera.zoom += 0.01;
		}
		if (window.input.check(Key.DOWN))
		{
			camera.zoom -= 0.01;
		}

		camera.update(window);

		lastPos = window.input.check(MouseButton.LEFT) ? camera.screenToCamera(window.input.mouse.position) : null;
	}

	public function draw(cameraPosition:Vector3) { }

	private var lastPos:Vector3;

}
