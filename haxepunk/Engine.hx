package haxepunk;

import haxe.ds.IntMap;
import haxepunk.graphics.Color;
import haxepunk.utils.Time;

#if lime

import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.graphics.Renderer;

class Engine extends Application
{

	override public function exec():Int
	{
		for (wnd in windows)
		{
			if (_windows.exists(wnd.id)) continue;
			registerWindow(wnd);
		}
		return super.exec();
	}

	public function ready(window:Window) {}

	public function addWindow(width:Int, height:Int, title:String="", ?background:Color):Window
	{
		var wnd = new lime.ui.Window({
			width: width,
			height: height,
			depthBuffer: true,
			resizable: true,
			x: 0, y: 0,
			hardware: true,
			title: title
		});
		createWindow(wnd);
		var window = registerWindow(wnd);
		if (background != null) window.backgroundColor = background;
		return window;
	}

	private function registerWindow(wnd:lime.ui.Window):Window
	{
		var window = new Window();
		window.register(wnd);
		_windows.set(wnd.id, window);

		// check that rendering context is supported
		switch (wnd.renderer.context)
		{
			#if flash
			case FLASH(context):
				haxepunk.renderers.FlashRenderer.init(context, function() {
					window.ready = true;
					ready(window);
				});
			#end
			case OPENGL(_):
				window.ready = true;
				ready(window);
			default:
				throw "Rendering context is not supported!";
		}
		return window;
	}

	override public function render(renderer:Renderer):Void
	{
		var window = _windows.get(renderer.window.id);
		window.render();
	}

	override public function update(deltaTime:Int):Void
	{
		Time.elapsed = deltaTime / 1000.0;
		Time.totalElapsed += Time.elapsed;
		Time.frames += 1;

		for (id in _windows.keys())
		{
			_windows.get(id).update();
		}
	}

	private var _windows = new IntMap<Window>();

}

#end
