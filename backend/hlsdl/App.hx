package backend.hlsdl;

import haxepunk.HXP;
#if hlsdl
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

	var engine:Engine;

	var window:sdl.Window;

	public function new() {
		var title = "Test";
		width = 320;
		height = 280;
		sdl.Sdl.init();
		window = new sdl.Window(title, width, height);

		// lime enables this by default so do this in linc as well
		GL.enable(GL.BLEND);
	}

	@:access(haxepunk.Engine)
	public function init(engine:Engine)
	{
		engine.checkScene();
		engine.init();
		engine._rate = 1000 / HXP.assignedFrameRate;
		engine._last = getTimeMillis();
		this.engine = engine;
		resize();
		run();
	}

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

	public function getTimeMillis():Float return 0;
	public function getMemoryUse():Float return 0;

	public function multiTouchSupported():Bool return false;

	public function getMouseX():Float return 0;
	public function getMouseY():Float return 0;
}
#end
