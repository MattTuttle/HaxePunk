package haxepunk.backend.hl;

#if hlsdl
import haxepunk.utils.Log;
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

	static var CODEMAP = [for( i in 0...2048 ) i];

	var mouseX:Float = 0;
	var mouseY:Float = 0;

	var engine:Engine;

	var window:sdl.Window;

	// Need a vertex array for desktop OpenGL
	var commonVA:VertexArray;

	public function new()
	{
		var title = "HaxePunk";
		initChars();
		sdl.Sdl.init();
		window = new sdl.Window(title, HXP.width, HXP.height);

		// lime enables this by default so do this in hl as well
		GL.enable(GL.BLEND);

		var v = GL.getParameter(GL.VERSION);
		var glES:Null<Float> = null;
		var reg = ~/ES ([0-9]+\.[0-9]+)/;
		if (reg.match(v))
		{
			glES = Std.parseFloat(reg.matched(1));
		}

		if (glES == null)
		{
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
				if( e.keyCode & (1 << 30) != 0 ) e.keyCode = (e.keyCode & ((1 << 30) - 1)) + 1000;
				Key.onKeyDown(CODEMAP[e.keyCode], shift);
			case KeyUp:
				if( e.keyCode & (1 << 30) != 0 ) e.keyCode = (e.keyCode & ((1 << 30) - 1)) + 1000;
				Key.onKeyUp(CODEMAP[e.keyCode]);
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

	static function initChars():Void
	{
		// Pulled from heaps for key mapping
		inline function addKey(sdl, keyCode) {
			CODEMAP[sdl] = keyCode;
		}

		// ASCII
		for( i in 0...26 )
			addKey(97 + i, Key.A + i);
		for( i in 0...12 )
			addKey(1058 + i, Key.F1 + i);
		for( i in 0...12 )
			addKey(1104 + i, Key.F13 + i);

		// NUMPAD
		addKey(1087, Key.NUMPAD_ADD);
		addKey(1088, Key.NUMPAD_ENTER);
		for( i in 0...9 )
			addKey(1089 + i, Key.NUMPAD_1 + i);
		addKey(1098, Key.NUMPAD_0);

		// EXTRA
		var keys = [
			1077 => Key.END,
			1074 => Key.HOME,
			1080 => Key.LEFT,
			1082 => Key.UP,
			1079 => Key.RIGHT,
			1081 => Key.DOWN,
			1073 => Key.INSERT,
			127 => Key.DELETE,
			//Key.NUMPAD_0-9
			//Key.A-Z
			//Key.F1-F12
			1087 => Key.NUMPAD_ADD,
			1088 => Key.NUMPAD_ENTER,
			1057 => Key.CAPS_LOCK,
			// Because hlsdl uses sym code, instead of scancode - INTL_BACKSLASH always reports 0x5C, e.g. regular slash.
			//none => Key.INTL_BACKSLASH
			//1070 => Key.PRINT_SCREEN
		];
		for( sdl in keys.keys() )
			addKey(sdl, keys.get(sdl));
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
		HXP.audio.quit();
		Sdl.quit();
		Sys.exit(0);
	}

	function resize()
	{
		var width = window.width;
		var height = window.height;
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
