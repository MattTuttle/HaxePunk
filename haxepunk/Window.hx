package haxepunk;

import haxepunk.debug.*;
import haxepunk.graphics.Color;
import haxepunk.inputs.Input;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import haxepunk.scene.Scene;
import haxepunk.utils.Time;

class Window
{

	/**
	 * An average fps of the last several frames.
	 */
	public var fps(default, null):Float = 0;

	/**
	 * The window's debug console.
	 */
	public var console:Console;

	/**
	 * Active scene. Changing will not take place until the next update
	 */
	public var scene(get, set):Scene;
	private inline function get_scene():Scene { return _scene; }
	private inline function set_scene(scene:Scene):Scene { return replaceScene(scene); }

	/**
	 * The width of the window
	 */
	public var width(get, set):Int;
	private inline function set_width(value:Int):Int { return _window.width = value; }
	private inline function get_width():Int { return _window.width; }

	/**
	 * The height of the window
	 */
	public var height(get, set):Int;
	private inline function set_height(value:Int):Int { return _window.height = value; }
	private inline function get_height():Int { return _window.height; }

	/**
	 * Pixel scale for window (retina mode).
	 */
	public var pixelScale(get, never):Float;
	private inline function get_pixelScale():Float { return _window.scale; }

	/**
	 * Window identifier.
	 */
	public var id(get, never):Int;
	private inline function get_id():Int { return _window.id; }

	/**
	 * Time taken for render frames.
	 */
	public var renderFrameTime(default, null):Statistic;

	/**
	 * Time taken for update frames.
	 */
	public var updateFrameTime(default, null):Statistic;

	/**
	 * The background color for the window.
	 */
	public var backgroundColor:Color;

	/**
	 * Input handler
	 */
	public var input:Input;

    public function new(?window:lime.ui.Window)
    {
		console = new Console();
		renderFrameTime = new Statistic(50, new Color(0.71, 0.29, 0.15));
		updateFrameTime = new Statistic(50, new Color(1.0, 0.94, 0.65));
		_frameTime = new Statistic(50, new Color(0.27, 0.54, 0.4));
		updateFrameTime.max = renderFrameTime.max = 1000 / 60;
		_frameTime.max = 1000 / 30;

		console.addStat(renderFrameTime);
		console.addStat(updateFrameTime);
		console.addStat(_frameTime);

		_scenes = new List<Scene>();
		_scene = new Scene();
		pushScene(_scene);

#if !unit_test
		_window = window;
		backgroundColor = new Color().fromInt(window.config.background);

		// reset viewport when window is resized or moved
		window.onResize.add(setViewport);
		window.onMove.add(function(x, y) {
			// for some reason the viewport needs to be set when the window moves
			setViewport(width, height);
		});
		setViewport(width, height);
#end
		// Init the input system
		input = new Input(window);
    }

	public function render()
	{
		// calculate time since last frame
		var startTime = Time.now;
		_frameTime.add(startTime - _lastFrame);
		fps = 1000 / _frameTime.average;
		_lastFrame = startTime;

		Renderer.window = this;
		Renderer.clear(scene.camera.clearColor == null ? backgroundColor : scene.camera.clearColor);
		scene.draw();
		if (console.enabled) console.draw(this);
		Renderer.present();
		renderFrameTime.add(Time.since(startTime));

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
		scene.update(this);

		if (console.enabled) console.update(this);

		// Update the input system
		input.update();

		updateFrameTime.add(Time.since(startTime));
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

	private var _lastFrame:Float = 0;
	private var _frameTime:Statistic;
	private var _window:lime.ui.Window;
	private var _scene:Scene;
	private var _scenes:List<Scene>;

}
