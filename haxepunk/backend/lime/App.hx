package haxepunk.backend.lime;

import haxepunk.backend.flash.graphics.hardware.Texture;

class App extends haxepunk.backend.flash.FlashApp
{
	#if (openfl >= "8.0.0")
	override function onEnterFrame(e)
	{
		invalidate();
		super.onEnterFrame(e);
	}
	#end

	override function initRenderer()
	{
		#if (openfl >= "8.0.0")
		// use the RenderEvent API
		addEventListener(openfl.events.RenderEvent.RENDER_OPENGL, function(event) {
			#if (openfl >= "8.9.2")
			var renderer:openfl._internal.renderer.context3D.Context3DRenderer = cast event.renderer;
			#else
			var renderer:openfl.display.OpenGLRenderer = cast event.renderer;
			Texture.gl = renderer.gl;
			#end
			Texture.renderer = renderer;
			engine.onRender();
		});
		#else
		// create an OpenGLView object and use the engine's render method
		var view = new openfl.display.OpenGLView();
		view.render = function(rect:openfl.geom.Rectangle)
		{
			engine.onRender();
		};
		addChild(view);
		#end
	}
}
