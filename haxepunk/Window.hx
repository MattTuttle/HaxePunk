package haxepunk;

import haxepunk.graphics.Color;
import haxepunk.inputs.Input;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import haxepunk.scene.Scene;
import haxepunk.utils.Time;

class Window
{

	/**
	 * Active scene. Changing will not take place until the next update
	 */
	public var scene(get, set):Scene;
	private inline function get_scene():Scene { return _scene; }
	private inline function set_scene(scene:Scene):Scene { return replaceScene(scene); }

	/**
	 * The width of the window
	 */
	public var width(get, never):Int;
	private inline function get_width():Int { return _window.width; }

	/**
	 * The height of the window
	 */
	public var height(get, never):Int;
	private inline function get_height():Int { return _window.height; }

	/**
	 * Pixel scale for window (retina mode).
	 */
	public var pixelScale(get, never):Float;
	private inline function get_pixelScale():Float { return _window.scale; }

	/**
	 * Time taken for last render frame.
	 */
	public var renderFrameTime(default, null):Float;

	/**
	 * Time taken for last update frame.
	 */
	public var updateFrameTime(default, null):Float;

	/**
	 * The background color for the window.
	 */
	public var backgroundColor:Color;

    public function new(window:lime.ui.Window)
    {
		_scenes = new List<Scene>();
		_scene = new Scene();
		pushScene(_scene);

		_window = window;
		backgroundColor = new Color().fromInt(window.config.background);

		// reset viewport when window is resized or moved
		window.onResize.add(setViewport);
		window.onMove.add(function(x, y) {
			// for some reason the viewport needs to be set when the window moves
			setViewport(width, height);
		});
		setViewport(width, height);

		// Init the input system
		Input.init(window);
    }

	public function render()
	{
		var startTime = Time.now;
		Renderer.clear(scene.camera.clearColor == null ? backgroundColor : scene.camera.clearColor);
		scene.draw();
		renderFrameTime = Time.since(startTime);

		#if flash
		// must reset program and texture at end of each frame...
		Renderer.bindProgram();
		Renderer.bindTexture(null, 0);
		#end
	}

	public function update()
	{
		var startTime = Time.now;
		// only change active scene during update
		_scene = _scenes.first();
		scene.update();

		// Update the input system
		Input.update();

		updateFrameTime = Time.since(startTime);
	}

	/**
	 * Update the viewport
	 */
	private function setViewport(windowWidth:Int, windowHeight:Int):Void
	{
		// get camera viewport
		var vp = scene.camera.setViewport(windowWidth, windowHeight);
		// set the window viewport
		Renderer.setViewport(new Rectangle(vp.x * pixelScale, vp.y * pixelScale,
			vp.width * pixelScale, vp.height * pixelScale));
	}

	/**
	 * Replaces the current scene
	 * @param scene The replacement scene
	 */
	public function replaceScene(scene:Scene):Scene
	{
		_scenes.pop();
		_scenes.push(scene);
		return scene;
	}

	/**
	 * Pops a scene from the stack
	 */
	public function popScene():Scene
	{
		// should always have at least one scene
		return (_scenes.length > 1 ? _scenes.pop() : _scenes.first());
	}

	/**
	 * Pushes a scene (keeping the old one to use later)
	 * @param scene The scene to push
	 */
	public function pushScene(scene:Scene):Scene
	{
		_scenes.push(scene);
		return scene;
	}

	private var _window:lime.ui.Window;
	private var _scene:Scene;
	private var _scenes:List<Scene>;

}
