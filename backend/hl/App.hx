package backend.hl;

import haxepunk.utils.Log;
#if hlsdl
import haxepunk.input.Gamepad;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.input.Input;
import haxepunk.HXP;
import haxepunk.Engine;
import sdl.Sdl;
import sdl.GL;

class App implements haxepunk.App
{
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	var width:Int;
	var height:Int;

	var mouseX:Float = 0;
	var mouseY:Float = 0;

	var engine:Engine;

	var window:sdl.Window;

	// Need a vertex array for desktop OpenGL
	var commonVA:VertexArray;

	public function new() {
		var title = "Test";
		width = 320;
		height = 280;
		sdl.Sdl.init();
		window = new sdl.Window(title, width, height);

		// lime enables this by default so do this in linc as well
		GL.enable(GL.BLEND);

		var v = GL.getParameter(GL.VERSION);
		var glES:Null<Float> = null;
		var reg = ~/ES ([0-9]+\.[0-9]+)/;
		if( reg.match(v) )
			glES = Std.parseFloat(reg.matched(1));

		if( glES == null ) {
			commonVA = GL.createVertexArray();
			GL.bindVertexArray( commonVA );
		}
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
		run();
	}

	@:access(haxepunk.input.Mouse)
	@:access(haxepunk.input.Key)
	@:access(haxepunk.input.Gamepad)
	function onEvent(e:sdl.Event):Bool
	{
		switch (e.type)
		{
			case WindowState:
				switch (e.state)
				{
					case Resize:
						resize();
					default:
				}
			case MouseDown:
				Mouse.onMouseDown(true);
			case MouseUp:
				Mouse.onMouseUp(true);
			case MouseWheel:
				Mouse.onMouseWheel(e.wheelDelta);
			case KeyDown:
				var shift = false; // TODO: determine shift key?
				Key.onKeyDown(e.keyCode, shift);
			case KeyUp:
				Key.onKeyUp(e.keyCode);
			case MouseMove:
				mouseX = e.mouseX;
				mouseY = e.mouseY;
			case TouchDown:
				Mouse.onMouseDown(true);
			case TouchUp:
				Mouse.onMouseUp(true);
			case GControllerAxis, JoystickAxisMotion:
				var joy:Gamepad = Gamepad.gamepad(e.joystick);
				joy.onAxisMove(e.button, e.value);
			case GControllerDown, JoystickButtonDown:
				var joy:Gamepad = Gamepad.gamepad(e.joystick);
				joy.onButtonDown(e.button);
			case GControllerUp, JoystickButtonUp:
				var joy:Gamepad = Gamepad.gamepad(e.joystick);
				joy.onButtonUp(e.button);
			case GControllerAdded, JoystickAdded:
				var joy = new Gamepad(e.joystick);
				Gamepad.gamepads[e.joystick] = joy;
				++Gamepad.gamepadCount;
				Input.handlers.push(joy);
				Gamepad.onConnect.invoke(joy);
			case GControllerRemoved, JoystickRemoved:
				var joy:Gamepad = Gamepad.gamepad(e.joystick);
				joy.connected = false;
				Gamepad.gamepads.remove(e.joystick);
				--Gamepad.gamepadCount;
				Input.handlers.remove(joy);
				Gamepad.onDisconnect.invoke(joy);
				Log.info('Gamepad (${joy.guid}: ${joy.name}) removed');
			case Quit:
				return true;
			default:
		}
		return true;
	}

	function mainLoop()
	{
		while (Sdl.processEvents(onEvent))
		{
			engine.onUpdate();

			var color = HXP.screen.color;
			GL.clearColor(color.red, color.green, color.blue, 1);
			GL.clear(GL.COLOR_BUFFER_BIT);
			engine.onRender();
			window.present();
		}
	}

	function run()
	{
		mainLoop();
		Sdl.quit();
		Sys.exit(0);
	}

	function resize()
	{
		width = window.width;
		height = window.height;
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

	public function getTimeMillis():Float
	{
		return haxe.Timer.stamp() * 1000;
	}

	public function getMemoryUse():Float return 0;

	public function multiTouchSupported():Bool return false;

	public function getMouseX():Float
	{
		return mouseX;
	}

	public function getMouseY():Float
	{
		return mouseY;
	}
}
#end
