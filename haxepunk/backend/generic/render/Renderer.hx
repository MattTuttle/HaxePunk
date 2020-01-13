package haxepunk.backend.generic.render;

import haxepunk.Scene;
import haxepunk.graphics.hardware.DrawCommand;

/**
 * OpenGL-based renderer. Based on work by @Yanrishatum and @Beeblerox.
 * @since	2.6.0
 */
interface Renderer
{
	public function render(drawCommand:DrawCommand):Void;

	public function startScene(scene:Scene):Void;

	public function flushScene(scene:Scene):Void;

	public function startFrame():Void;
	public function endFrame():Void;
}
