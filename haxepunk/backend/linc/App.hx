package haxepunk.backend.linc;

#if (linc_sdl && linc_opengl)

import haxepunk.graphics.hardware.ImageData;
import haxepunk.input.Mouse;
import haxepunk.utils.Color;
import sdl.Renderer;
import sdl.SDL;
import sdl.Window;
import sdl.Event;
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

	var window:Window;
	var engine:Engine;

	var width:Int;
	var height:Int;
	var mouseState:SDLMouseState;

	public function new(engine:Engine)
	{
		var title = "Test";
		width = 480;
		height = 320;
		this.engine = engine;
		SDL.init(SDL_INIT_VIDEO);
		window = SDL.createWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_RESIZABLE);
		SDL.GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
		SDL.GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
		SDL.GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
		SDL.GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		SDL.GL_SetSwapInterval(true);
		SDL.GL_CreateContext(window);
		GLEW.init();
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
		run();
	}

	function run()
	{
		while (update())
		{
			SDL.delay(16);
		}

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

	@:access(haxepunk.input.Mouse)
	function handleEvent(e:Event)
	{
		switch (e.type)
		{
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

	public function getSfx(name:String):Null<Sfx> return new OpenALSfx(name);

	public inline function getMemory():Int return 0;

	public inline function showCursor() SDL.showCursor(SDL_ENABLE);
	public inline function hideCursor() SDL.showCursor(SDL_DISABLE);

	public inline function getMouseX():Float return mouseState.x;
	public inline function getMouseY():Float return mouseState.y;
}

#end
