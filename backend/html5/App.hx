package backend.html5;

import backend.opengl.render.GLRenderer;
import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.GL;
import haxepunk.Engine;
import haxepunk.HXP;

class App implements haxepunk.App
{
	var engine:Engine;
	var canvas:CanvasElement;

	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	public function new()
	{
		trace("hello world");
		var el = Browser.document.getElementById("haxepunk");
		canvas = cast(el, CanvasElement);
		canvas.width = HXP.width;
		canvas.height = HXP.height;
	}

	@:access(haxepunk.Engine)
	public function init(engine:Engine)
	{
		this.engine = engine;
		resize();
		engine.checkScene();
		engine.init();
		engine._rate = 1000 / HXP.assignedFrameRate;
		engine._last = getTimeMillis();
		loop();
	}

	function resize()
	{
		HXP.width = canvas.width;
		HXP.height = canvas.height;
	}

	function loop(?elapsed:Float)
	{
		Browser.window.requestAnimationFrame(loop);
		var gl = canvas.getContextWebGL();
		GLRenderer.GL = gl;
		engine.onUpdate();

		var color = HXP.screen.color;
		gl.clearColor(color.red, color.green, color.blue, 1);
		gl.clear(GL.COLOR_BUFFER_BIT);
		engine.onRender();
	}

	public function getTimeMillis():Float
	{
		return haxe.Timer.stamp() * 1000;
	}

	public function getMemoryUse():Float return 0;

	public function multiTouchSupported():Bool return false;

	public function getMouseX():Float return 0;
	public function getMouseY():Float return 0;
}
