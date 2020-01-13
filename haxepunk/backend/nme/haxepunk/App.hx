package haxepunk;

#if nme

import nme.display.OpenGLView;
import nme.geom.Rectangle;

class App extends haxepunk.backend.flash.FlashApp
{
	override function initRenderer()
	{
		// create an OpenGLView object and use the engine's render method
		var view = new OpenGLView();
		view.render = function(rect:Rectangle)
		{
			engine.onRender();
		};
		addChild(view);
	}
}

#end
