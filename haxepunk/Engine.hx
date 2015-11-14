package haxepunk;

import haxe.ds.IntMap;
import haxepunk.graphics.Color;
import haxepunk.utils.Time;
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
			var window = new Window(window);
			_windows.set(wnd.id, window);
			// check that rendering context is supported
			switch (wnd.renderer.context)
			{
				#if flash
				case FLASH(context):
					Renderer.init(context, function() { ready(window); });
				#end
				case OPENGL(_):
					ready(window);
				default:
					throw "Rendering context is not supported!";
			}
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
		var window = new Window(wnd);
		if (background != null) window.backgroundColor = background;
		_windows.set(wnd.id, window);
		ready(window);
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
