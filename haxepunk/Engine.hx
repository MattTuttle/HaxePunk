package haxepunk;

import haxepunk.graphics.Material;
import haxepunk.inputs.Input;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import haxepunk.scene.Scene;
import haxepunk.utils.Time;
import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;

class Engine extends Application
{

	public var scene(get, set):Scene;
	private inline function get_scene():Scene { return _scenes.first(); }
	private inline function set_scene(scene:Scene):Scene { return replaceScene(scene); }

	public function new(?scene:Scene)
	{
		super();
		_scenes = new List<Scene>();
		pushScene(scene == null ? new Scene() : scene);
	}

	override public function exec():Int
	{
		HXP.window = windows[0];

		HXP.window.onResize.add(setViewport);
		HXP.window.onMove.add(function(x, y) {
			// for some reason the viewport needs to be set when the window moves
			setViewport(HXP.window.width, HXP.window.height);
		});
		setViewport(HXP.window.width, HXP.window.height);

		// Init the input system
		Input.init(HXP.window);

		switch (HXP.window.renderer.context)
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

		return super.exec();
	}

	/**
	 * This function is called when the engine is ready. All initialization code should go here.
	 */
	public function ready() { }

	private function setViewport(windowWidth:Int, windowHeight:Int)
	{
		if (scene.width == 0) scene.width = windowWidth;
		if (scene.height == 0) scene.height = windowHeight;
		var x = 0, y = 0, scale = 1.0,
			width = scene.width, height = scene.height;
		switch (HXP.scaleMode)
		{
			case NoScale:
				// Nothing to do
			case Zoom:
				scale = windowWidth / width;
				if (scale * height < windowHeight)
				{
					scale = windowHeight / height;
				}
			case LetterBox:
				scale = windowWidth / width;
				if (scale * height > windowHeight)
				{
					scale = windowHeight / height;
				}
			case Stretch:
				width = windowWidth;
				height = windowHeight;
		}
		width = Std.int(width * scale);
		height = Std.int(height * scale);
		var pixelScale = HXP.window.scale; // for retina devices
		x = Std.int((windowWidth - width) / 2 * pixelScale);
		y = Std.int((windowHeight - height) / 2 * pixelScale);
		Renderer.setViewport(x, y, Std.int(width * pixelScale), Std.int(height * pixelScale));
	}

	override public function render(renderer:lime.graphics.Renderer):Void
	{
		var startTime = Time.current;
		scene.draw();
		Time.renderFrameTime = Time.since(startTime);

		#if flash
		// must reset program and texture at end of each frame...
		Renderer.bindProgram();
		Renderer.bindTexture(null, 0);
		#end
	}

	override public function update(deltaTime:Int):Void
	{
		var startTime = Time.current;
		Time.elapsed = deltaTime / 1000.0;
		Time.totalElapsed += Time.elapsed;
		Time.frames += 1;

		scene.update();

		// Update the input system
		Input.update();
		Time.updateFrameTime = Time.since(startTime);
	}

	/**
	 * Replaces the current scene
	 * @param scene The replacement scene
	 */
	public function replaceScene(scene:Scene):Scene
	{
		_scenes.pop();
		_scenes.push(scene);
		return HXP.scene = scene;
	}

	/**
	 * Pops a scene from the stack
	 */
	public function popScene():Scene
	{
		// should always have at least one scene
		return HXP.scene = (_scenes.length > 1 ? _scenes.pop() : _scenes.first());
	}

	/**
	 * Pushes a scene (keeping the old one to use later)
	 * @param scene The scene to push
	 */
	public function pushScene(scene:Scene):Scene
	{
		_scenes.push(scene);
		return HXP.scene = scene;
	}

	private var _scenes:List<Scene>;

}
