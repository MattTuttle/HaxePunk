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

	/**
	 * Active scene. Changing will not take place until the next update
	 */
	public static var scene(get, set):Scene;
	private inline static function get_scene():Scene { return _scene; }
	private inline static function set_scene(scene:Scene):Scene { return replaceScene(scene); }

	public function new(?scene:Scene)
	{
		super();
		_scenes = new List<Scene>();
		_scene = scene == null ? new Scene() : scene;
		pushScene(_scene);
	}

	override public function exec():Int
	{
		HXP.window = windows[0];

		// reset viewport when window is resized or moved
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

	/**
	 * Update the viewport
	 */
	private function setViewport(windowWidth:Int, windowHeight:Int):Void
	{
		var viewport = scene.camera.setViewport(windowWidth, windowHeight);
		Renderer.setViewport(viewport);
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

		// only change active scene during update
		_scene = _scenes.first();
		scene.update();

		// Update the input system
		Input.update();
		Time.updateFrameTime = Time.since(startTime);
	}

	/**
	 * Replaces the current scene
	 * @param scene The replacement scene
	 */
	public static function replaceScene(scene:Scene):Scene
	{
		_scenes.pop();
		_scenes.push(scene);
		return scene;
	}

	/**
	 * Pops a scene from the stack
	 */
	public static function popScene():Scene
	{
		// should always have at least one scene
		return (_scenes.length > 1 ? _scenes.pop() : _scenes.first());
	}

	/**
	 * Pushes a scene (keeping the old one to use later)
	 * @param scene The scene to push
	 */
	public static function pushScene(scene:Scene):Scene
	{
		_scenes.push(scene);
		return scene;
	}

	private static var _scene:Scene;
	private static var _scenes:List<Scene>;

}
