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
		window.register(wnd, this.ready);
		_windows.set(wnd.id, window);
		return window;
	}

	override public function render(renderer:Renderer):Void
	{
		_windows.get(renderer.window.id).render();
	}

	override public function update(deltaTime:Int):Void
	{
		Time.elapsed = deltaTime / 1000.0;
		Time.totalElapsed += Time.elapsed;
		Time.frames += 1;

		for (window in _windows)
		{
			window.update();
		}
	}

	private var _windows = new IntMap<Window>();

}

#end
