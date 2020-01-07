package backend.html5;

import haxepunk.math.MathUtil;
import haxepunk.input.Mouse;
import haxepunk.input.Key;
import backend.opengl.render.GLRenderer;
import js.Browser;
import js.html.CanvasElement;
import haxepunk.Engine;
import haxepunk.HXP;

class App implements haxepunk.App
{
	var engine:Engine;
	var canvas:CanvasElement;
	var mouseX:Float;
	var mouseY:Float;

	static var CODEMAP = [for( i in 0...2048 ) i];

	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	public function new()
	{
		initChars();
		var el = Browser.document.getElementById("haxepunk");
		canvas = cast(el, CanvasElement);
		canvas.width = HXP.width;
		canvas.height = HXP.height;
		GLRenderer._GL = canvas.getContextWebGL({ alpha: false });

		listenForEvents();
	}

	static function initChars():Void
	{
		// Pulled from heaps for key mapping
		inline function addKey(web, keyCode) {
			CODEMAP[web] = keyCode;
		}

		// ASCII
		for (i in 0...26)
			addKey(65 + i, Key.A + i);
		for (i in 0...12)
			addKey(112 + i, Key.F1 + i);
	
		addKey(37, Key.LEFT);
		addKey(38, Key.UP);
		addKey(39, Key.RIGHT);
		addKey(40, Key.DOWN);
	}

	@:access(haxepunk.input.Mouse)
	@:access(haxepunk.input.Key)
	function listenForEvents()
	{
		var doc = Browser.document;
		doc.addEventListener('mousemove', function(e) {
			mouseX = MathUtil.clamp(e.clientX - canvas.offsetLeft, 0, HXP.width);
			mouseY = MathUtil.clamp(e.clientY - canvas.offsetTop, 0, HXP.height);
		});
		doc.addEventListener('mousedown', function(e) {
			Mouse.onMouseDown(e.button);
		});
		doc.addEventListener('mouseup', function(e) {
			Mouse.onMouseUp(e.button);
		});
		doc.addEventListener('keydown', function(e) {
			Key.onKeyDown(CODEMAP[e.keyCode], false);
		});
		doc.addEventListener('keyup', function(e) {
			Key.onKeyUp(CODEMAP[e.keyCode]);
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
