package haxepunk;

import haxepunk.utils.Time;
import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.graphics.Renderer;

class Engine extends Application
{

	override public function exec():Int
	{
		for (window in windows)
		{
			var wnd = HXP.window = new Window(window);
			_windows.push(wnd);
			switch (window.renderer.context)
			{
				#if flash
				case FLASH(stage):
					Renderer.init(stage, ready);
				#end
				case OPENGL(gl):
					ready();
				default:
					throw "Rendering context is not supported!";
			}
		}
		return super.exec();
	}

	/**
	 * This function is called when the engine is ready. All initialization code should go here.
	 */
	public function ready() { }

	override public function render(renderer:Renderer):Void
	{
		for (window in _windows)
		{
			HXP.window = window; // HACK! Remove this!!!
			window.render();
		}
	}

	override public function update(deltaTime:Int):Void
	{
		Time.elapsed = deltaTime / 1000.0;
		Time.totalElapsed += Time.elapsed;
		Time.frames += 1;

		for (window in _windows)
		{
			HXP.window = window; // HACK! Remove this!!!
			window.update();
		}
	}

	private var _windows:Array<Window> = [];

}
