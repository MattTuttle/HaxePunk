package backend.html5;

import haxepunk.input.Mouse;
import js.lib.Date;
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
	var mouseX:Int;
	var mouseY:Int;

	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	public function new()
	{
		var el = Browser.document.getElementById("haxepunk");
		canvas = cast(el, CanvasElement);
		canvas.width = HXP.width;
		canvas.height = HXP.height;
		GLRenderer._GL = canvas.getContextWebGL({ alpha: false });

		listenForEvents();
	}

	@:access(haxepunk.input.Mouse)
	function listenForEvents()
	{
		canvas.addEventListener('mousemove', function(e) {
			mouseX = e.mouseX;
			mouseY = e.mouseY;
		});
		canvas.addEventListener('mousedown', function(e) {
			Mouse.onMouseDown(e.button);
		});
		canvas.addEventListener('mouseup', function(e) {
			Mouse.onMouseUp(e.button);
		});
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
		var width = canvas.width;
		var height = canvas.height;
		if (HXP.width == 0 || HXP.height == 0)
		{
			// set initial size
			HXP.width = width;
			HXP.height = height;
			HXP.screen.scaleMode.setBaseSize();
		}
		HXP.resize(width, height);
		engine.onResize.invoke();
	}

	function loop(?elapsed:Float)
	{
		Browser.window.requestAnimationFrame(loop);
		engine.onUpdate();

		GLRenderer.clear(HXP.screen.color);
		engine.onRender();
	}

	public function getTimeMillis():Float
	{
		return haxe.Timer.stamp() * 1000;
	}

	public function getMemoryUse():Float return 0;

	public function multiTouchSupported():Bool return false;

	public function getMouseX():Float return mouseX;
	public function getMouseY():Float return mouseY;
}
