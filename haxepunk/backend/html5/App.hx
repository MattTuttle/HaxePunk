package haxepunk.backend.html5;

#if js

import haxe.Int64;
import js.Browser;
import js.html.TouchEvent;
import js.html.MouseEvent;
import js.html.KeyboardEvent;
import js.html.HTMLDocument;
import js.html.CanvasElement;

import haxepunk.math.MathUtil;
import haxepunk.input.Mouse;
import haxepunk.input.Key;
import haxepunk.input.Touch;
import haxepunk.input.Input;
import haxepunk.backend.opengl.GL;
import haxepunk.backend.opengl.GLRenderer;
import haxepunk.Engine;
import haxepunk.HXP;

class App implements haxepunk.App
{
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	// used in GLUtils.replaceGL macro
	public static var gl:GL;

	public function new()
	{
		var el = Browser.document.getElementById("haxepunk");
		canvas = cast(el, CanvasElement);
		gl = canvas.getContextWebGL({ alpha: false });
		gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
		gl.enable(GL.BLEND);

		var doc = Browser.document;
		listenForMouseEvents(doc);
		listenForKeyEvents(doc);
		listenForTouchEvents(doc);
		Browser.window.addEventListener('resize', resize);
		canvas.addEventListener('resize', resize);
		doc.addEventListener('visibilitychange', function() {
			HXP.focused = !doc.hidden;
			if (HXP.focused) {
				engine.focusGained();
				engine.scene.focusGained();
			} else {
				engine.focusLost();
				engine.scene.focusLost();
			}
		});
	}

	inline function mapKeys(code:Int):Int
	{
		// any keys that don't map directly to their counterparts in Key are converted here
		return switch (code) {
			case 192: Key.TILDE;
			case 224: Key.COMMAND;
			default: code;
		}
	}

	public function showCursor():Void
	{
		canvas.style.cursor = 'default';
	}

	public function hideCursor():Void
	{
		canvas.style.cursor = 'none';
	}

	@:access(haxepunk.input.Mouse)
	function listenForMouseEvents(doc:HTMLDocument)
	{
		var rect = canvas.getBoundingClientRect();
		doc.addEventListener('mousemove', function(e:MouseEvent) {
			mouseX = MathUtil.clamp(e.pageX - rect.left, 0, HXP.windowWidth);
			mouseY = MathUtil.clamp(e.pageY - rect.top, 0, HXP.windowHeight);
		});
		doc.addEventListener('mousedown', function(e:MouseEvent) {
			Mouse.onMouseDown(e.button);
		});
		doc.addEventListener('mouseup', function(e:MouseEvent) {
			Mouse.onMouseUp(e.button);
		});
	}

	@:access(haxepunk.input.Key)
	function listenForKeyEvents(doc:HTMLDocument)
	{
		doc.addEventListener('keydown', function(e:KeyboardEvent) {
			// prevent arrow key and spacebar scrolling
			switch (e.keyCode) {
				case 37, 39, 38, 40, 32:
					e.preventDefault();
			}
			Key.onKeyDown(mapKeys(e.keyCode), false);
		});
		doc.addEventListener('keyup', function(e:KeyboardEvent) {
			Key.onKeyUp(mapKeys(e.keyCode));
		});
	}

	@:access(haxepunk.input.Touch)
	function listenForTouchEvents(doc:HTMLDocument)
	{
		Input.handlers.push(Touch);
		doc.addEventListener('touchstart', function(e:TouchEvent) {
			for (touch in e.targetTouches)
			{
				var id = touch.identifier;
				var touchPoint = new Touch(e.pageX / HXP.screen.scaleX, e.pageY / HXP.screen.scaleY, id);
				Touch._touches.set(id, touchPoint);
				Touch._touchOrder.push(id);
			}
		});
		doc.addEventListener('touchmove', function(e:TouchEvent) {
			// if more than one touch is given, update multi touch as supported
			if (e.touches.length > 1)
			{
				multiTouchSupport = true;
			}
			for (touch in e.targetTouches)
			{
				var id = touch.identifier;
				if (Touch._touches.exists(id))
				{
					var point = Touch._touches.get(id);
					point.x = e.pageX / HXP.screen.scaleX;
					point.y = e.pageY / HXP.screen.scaleY;
				}
			}
		});
		doc.addEventListener('touchend', function(e:TouchEvent) {
			for (touch in e.targetTouches)
			{
				var id = touch.identifier;
				if (Touch._touches.exists(id))
				{
					Touch._touches.get(id).released = true;
				}
			}
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
		var width = canvas.clientWidth;
		var height = canvas.clientHeight;
		canvas.width = width;
		canvas.height = height;
		if (HXP.width == 0 || HXP.height == 0)
		{
			// set initial size
			HXP.screen.scaleMode.setBaseSize(width, height);
		}
		HXP.resize(width, height);
		engine.onResize.invoke();
	}

	function loop(?elapsed:Float)
	{
		Browser.window.requestAnimationFrame(loop);
		engine.onUpdate();

		engine.onRender();
	}

	public function getTimeMillis():Float
	{
		return haxe.Timer.stamp() * 1000;
	}

	public function getMemoryUse():Int64
	{
		// window.performance.memory is only available on Chrome
		return js.Syntax.code('(window.performance && window.performance.memory) ? window.performance.memory.usedJSHeapSize : 0');
	}

	public function multiTouchSupported():Bool return multiTouchSupport;

	public function getMouseX():Float return mouseX;
	public function getMouseY():Float return mouseY;

	var engine:Engine;
	var canvas:CanvasElement;
	var mouseX:Float;
	var mouseY:Float;
	var multiTouchSupport:Bool = false;
}

#end
