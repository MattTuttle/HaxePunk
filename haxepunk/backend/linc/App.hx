package haxepunk.backend.linc;

#if (linc_sdl && linc_opengl)

import haxe.ds.IntMap;
import haxepunk.audio.AudioSystem;
import haxepunk.backend.linc.audio.OpenALSystem;
import haxepunk.graphics.hardware.ImageData;
import haxepunk.input.Mouse;
import haxepunk.input.Key;
import haxepunk.utils.Color;
import sdl.Renderer;
import sdl.SDL;
import sdl.Window;
import sdl.Event;
import sdl.Keycodes;
import glew.GLEW;
import opengl.GL.*;

@:enum
abstract SDLMouseButton(Int)
from Int to Int {
	var SDL_BUTTON_LEFT   = 1;
	var SDL_BUTTON_MIDDLE = 2;
	var SDL_BUTTON_RIGHT  = 3;
	// var SDL_BUTTON_X1     = 4;
	// var SDL_BUTTON_X2     = 5;
}

class App implements haxepunk.App
{
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return false;

	public var audio(default, null):AudioSystem;
	public var assets(default, null) = new Assets();

	var window:Window;
	var engine:Engine;

	var width:Int;
	var height:Int;
	var mouseState:SDLMouseState;

	public function new(engine:Engine)
	{
		var title = "Test";
		width = 320;
		height = 280;
		this.engine = engine;
		this.audio = new OpenALSystem();
		SDL.init(SDL_INIT_VIDEO);
		window = SDL.createWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_RESIZABLE);
		SDL.GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
		SDL.GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
		SDL.GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
		SDL.GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		SDL.GL_SetSwapInterval(true);
		SDL.GL_CreateContext(window);
		GLEW.init();

		// lime enables this by default so do this in linc as well
		glEnable(GL_BLEND);

		mouseState = {x: 0, y:0, buttons:0};
	}

	@:access(haxepunk.Engine)
	public function init()
	{
		engine.checkScene();
		engine.init();
		engine._rate = 1000 / HXP.assignedFrameRate;
		engine._last = getTimeMillis();
		resize();
		initKeymap();
		run();
	}

	function initKeymap()
	{
		keymap.set(Keycodes.left, Key.LEFT);
		keymap.set(Keycodes.up, Key.UP);
		keymap.set(Keycodes.right, Key.RIGHT);
		keymap.set(Keycodes.down, Key.DOWN);

		keymap.set(Keycodes.enter, Key.ENTER);
		keymap.set(Keycodes.space, Key.SPACE);
		keymap.set(Keycodes.backspace, Key.BACKSPACE);
		keymap.set(Keycodes.capslock, Key.CAPS_LOCK);
		keymap.set(Keycodes.delete, Key.DELETE);
		keymap.set(Keycodes.end, Key.END);
		keymap.set(Keycodes.escape, Key.ESCAPE);
		keymap.set(Keycodes.home, Key.HOME);
		keymap.set(Keycodes.insert, Key.INSERT);
		keymap.set(Keycodes.tab, Key.TAB);
		keymap.set(Keycodes.pagedown, Key.PAGE_DOWN);
		keymap.set(Keycodes.pageup, Key.PAGE_UP);
		keymap.set(Keycodes.leftbracket, Key.LEFT_SQUARE_BRACKET);
		keymap.set(Keycodes.rightbracket, Key.RIGHT_SQUARE_BRACKET);
		keymap.set(Keycodes.backquote, Key.TILDE);

		keymap.set(Keycodes.key_a, Key.A);
		keymap.set(Keycodes.key_b, Key.B);
		keymap.set(Keycodes.key_c, Key.C);
		keymap.set(Keycodes.key_d, Key.D);
		keymap.set(Keycodes.key_e, Key.E);
		keymap.set(Keycodes.key_f, Key.F);
		keymap.set(Keycodes.key_g, Key.G);
		keymap.set(Keycodes.key_h, Key.H);
		keymap.set(Keycodes.key_i, Key.I);
		keymap.set(Keycodes.key_j, Key.J);
		keymap.set(Keycodes.key_k, Key.K);
		keymap.set(Keycodes.key_l, Key.L);
		keymap.set(Keycodes.key_m, Key.M);
		keymap.set(Keycodes.key_n, Key.N);
		keymap.set(Keycodes.key_o, Key.O);
		keymap.set(Keycodes.key_p, Key.P);
		keymap.set(Keycodes.key_q, Key.Q);
		keymap.set(Keycodes.key_r, Key.R);
		keymap.set(Keycodes.key_s, Key.S);
		keymap.set(Keycodes.key_t, Key.T);
		keymap.set(Keycodes.key_u, Key.U);
		keymap.set(Keycodes.key_v, Key.V);
		keymap.set(Keycodes.key_w, Key.W);
		keymap.set(Keycodes.key_x, Key.X);
		keymap.set(Keycodes.key_y, Key.Y);
		keymap.set(Keycodes.key_z, Key.Z);

		keymap.set(Keycodes.f1, Key.F1);
		keymap.set(Keycodes.f2, Key.F2);
		keymap.set(Keycodes.f3, Key.F3);
		keymap.set(Keycodes.f4, Key.F4);
		keymap.set(Keycodes.f5, Key.F5);
		keymap.set(Keycodes.f6, Key.F6);
		keymap.set(Keycodes.f7, Key.F7);
		keymap.set(Keycodes.f8, Key.F8);
		keymap.set(Keycodes.f9, Key.F9);
		keymap.set(Keycodes.f10, Key.F10);
		keymap.set(Keycodes.f11, Key.F11);
		keymap.set(Keycodes.f12, Key.F12);
		keymap.set(Keycodes.f13, Key.F13);
		keymap.set(Keycodes.f14, Key.F14);
		keymap.set(Keycodes.f15, Key.F15);

		keymap.set(Keycodes.key_0, Key.DIGIT_0);
		keymap.set(Keycodes.key_1, Key.DIGIT_1);
		keymap.set(Keycodes.key_2, Key.DIGIT_2);
		keymap.set(Keycodes.key_3, Key.DIGIT_3);
		keymap.set(Keycodes.key_4, Key.DIGIT_4);
		keymap.set(Keycodes.key_5, Key.DIGIT_5);
		keymap.set(Keycodes.key_6, Key.DIGIT_6);
		keymap.set(Keycodes.key_7, Key.DIGIT_7);
		keymap.set(Keycodes.key_8, Key.DIGIT_8);
		keymap.set(Keycodes.key_9, Key.DIGIT_9);

		keymap.set(Keycodes.kp_0, Key.NUMPAD_0);
		keymap.set(Keycodes.kp_1, Key.NUMPAD_1);
		keymap.set(Keycodes.kp_2, Key.NUMPAD_2);
		keymap.set(Keycodes.kp_3, Key.NUMPAD_3);
		keymap.set(Keycodes.kp_4, Key.NUMPAD_4);
		keymap.set(Keycodes.kp_5, Key.NUMPAD_5);
		keymap.set(Keycodes.kp_6, Key.NUMPAD_6);
		keymap.set(Keycodes.kp_7, Key.NUMPAD_7);
		keymap.set(Keycodes.kp_8, Key.NUMPAD_8);
		keymap.set(Keycodes.kp_9, Key.NUMPAD_9);
		keymap.set(Keycodes.kp_plus, Key.NUMPAD_ADD);
		keymap.set(Keycodes.kp_decimal, Key.NUMPAD_DECIMAL);
		keymap.set(Keycodes.kp_divide, Key.NUMPAD_DIVIDE);
		keymap.set(Keycodes.kp_enter, Key.NUMPAD_ENTER);
		keymap.set(Keycodes.kp_multiply, Key.NUMPAD_MULTIPLY);
		keymap.set(Keycodes.kp_minus, Key.NUMPAD_SUBTRACT);
	}

	function run()
	{
		while (update()) {}

		destroy();
	}

	function destroy()
	{
		audio.destroy();
		audio = null;

		engine.onClose.invoke();
		SDL.quit();
	}

	function resize()
	{
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

	inline function getKeycode(key)
	{
		return keymap.exists(key) ? keymap.get(key) : key;
	}

	@:access(haxepunk.input)
	function handleEvent(e:Event)
	{
		switch (e.type)
		{
			case SDL_KEYDOWN:
				var shift = (e.key.keysym.mod & 3) != 0;
				Key.onKeyDown(getKeycode(e.key.keysym.sym), shift);
			case SDL_KEYUP:
				Key.onKeyUp(getKeycode(e.key.keysym.sym));
			case SDL_MOUSEBUTTONDOWN:
				switch (e.button.button)
				{
					case SDL_BUTTON_LEFT:
						Mouse.onMouseDown();
					case SDL_BUTTON_RIGHT:
						Mouse.onRightMouseDown();
					case SDL_BUTTON_MIDDLE:
						Mouse.onMiddleMouseDown();
				}
			case SDL_MOUSEBUTTONUP:
				switch (e.button.button)
				{
					case SDL_BUTTON_LEFT:
						Mouse.onMouseUp();
					case SDL_BUTTON_RIGHT:
						Mouse.onRightMouseUp();
					case SDL_BUTTON_MIDDLE:
						Mouse.onMiddleMouseUp();
				}
			case SDL_MOUSEWHEEL:
				Mouse.onMouseWheel(e.wheel.y);
			default:
		}
	}

	function update()
	{
		while (SDL.hasAnEvent())
		{
			var e = SDL.pollEvent();
			if (e.type == SDL_QUIT) return false;
			handleEvent(e);
		}

		SDL.getMouseState(mouseState);

		engine.onUpdate();

		var color = HXP.screen.color;
		glClearColor(color.red, color.green, color.blue, 1);
		glClear(GL_COLOR_BUFFER_BIT);
		engine.onRender();
		SDL.GL_SwapWindow(window);

		return true;
	}

	public function getTimeMillis():Float return SDL.getTicks();

	public function multiTouchSupported():Bool return false;

	public function createImageData(width:Int, height:Int, transparent:Bool, color:Color):Null<ImageData>
	{
		return BytesImageData.create(width, height, transparent, color);
	}

	public function getImageData(name:String):Null<ImageData>
	{
		return BytesImageData.get(name);
	}

	public inline function getMemory():Int return 0;

	public inline function showCursor() SDL.showCursor(SDL_ENABLE);
	public inline function hideCursor() SDL.showCursor(SDL_DISABLE);

	public inline function getMouseX():Float return mouseState.x;
	public inline function getMouseY():Float return mouseState.y;

	var keymap = new IntMap<Int>();
}

#end
