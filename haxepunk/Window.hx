package haxepunk;

import haxepunk.debug.*;
import haxepunk.graphics.Color;
import haxepunk.inputs.Input;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import haxepunk.scene.*;
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
	 * The active renderer for this window.
	 */
	public var renderer(default, null):Renderer;

	/**
	 * Active scene. Changing will not take place until the next update
	 */
	public var scene(get, set):Scene;
	private inline function get_scene():Scene { return _scene; }
	private inline function set_scene(scene:Scene):Scene { replaceScene(scene); return scene; }

	public var nextScene(get, never):Scene;
	private inline function get_nextScene():Scene { return _scenes.first(); }

#if lime
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
#end

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

    public function new()
    {
		input = new Input();
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
    }

	/**
	 * Captures the scene to an image file
	 * @param filename the name of the screenshot file to generate
	 */
	public function capture(filename:String):Void
	{
#if !(html5 || flash)
		try {
			var viewport = scene.camera.viewport;
			var file = sys.io.File.write(filename);
			var format = filename.substr(filename.lastIndexOf(".") + 1);
			var image = renderer.capture(viewport);
			var bytes = image.encode(format);
			file.writeBytes(bytes, 0, bytes.length);
			file.close();
		} catch (e:Dynamic) {
			Log.error("Failed to capture screen: " + e);
		}
#end
	}

#if lime
	public function register(?window:lime.ui.Window, ready:Window->Void)
	{
		_window = window;
		backgroundColor = new Color().fromInt(window.config.background);

		// reset viewport when window is resized or moved
		window.onResize.add(setViewport);
		window.onMove.add(function(x, y) {
			// for some reason the viewport needs to be set when the window moves
			setViewport(width, height);
		});

		input.register(window);

		// check that rendering context is supported
		switch (window.renderer.context)
		{
#if flash
			case FLASH(context):
				renderer = new haxepunk.renderers.FlashRenderer(this, context, function() {
					setViewport(width, height);
					ready(this);
				});
#else
			case OPENGL(context):
				renderer = new haxepunk.renderers.GLRenderer(this, context);
				setViewport(width, height);
				ready(this);
#end
			default:
				throw "Rendering context is not supported!";
		}
	}
#end

	public function render()
	{
		// check if renderer is ready
		if (renderer == null) return;

		// calculate time since last frame
		var startTime = Time.now;
		_frameTime.add(startTime - _lastFrame);
		fps = 1000 / _frameTime.average;
		_lastFrame = startTime;

		if (_transition == null)
		{
			_scene.draw(renderer);
		}
		else
		{
			_transition.draw(renderer);
		}
		if (console.enabled) console.draw(this);
		renderer.present();
		renderFrameTime.add(Time.since(startTime));
	}

	public function update()
	{
		var startTime = Time.now;

		// only change active scene after update
		_scene = nextScene;
		_scene.update(this);

		if (_transition != null)
		{
			_transition.update(this);
		}

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
		renderer.setViewport(new Rectangle(vp.x * pixelScale, vp.y * pixelScale,
			vp.width * pixelScale, vp.height * pixelScale));
	}

	private function setTransition(?transition:Transition):Transition
	{
		if (transition != null)
		{
			transition.oldScene = this.scene;
			transition.newScene = this.nextScene;
			transition.finishTransition.connect(function() { _transition = null; });
		}
		return _transition = transition;
	}

	/**
	 * Replaces the current scene.
	 * @param scene       The scene to replace the current one.
	 * @param transition  A transition to be used between scenes.
	 * @return The scene transition
	 */
	public function replaceScene(scene:Scene, ?transition:Transition):Null<Transition>
	{
		_scenes.pop();
		return pushScene(scene, transition);
	}

	/**
	 * Pops a scene from the stack.
	 * @param transition  A transition to be used between scenes.
	 * @return The scene transition
	 */
	public function popScene(?transition:Transition):Null<Transition>
	{
		// should always have at least one scene
		if (_scenes.length > 1) _scenes.pop();
		return setTransition(transition);
	}

	/**
	 * Pushes a scene (keeping the old one to use later). Useful for pause menus.
	 * @param scene       Pushes a new scene onto the scene stack.
	 * @param transition  A transition to be used between scenes.
	 * @return The scene transition
	 */
	public function pushScene(scene:Scene, ?transition:Transition):Null<Transition>
	{
		_scenes.push(scene);
		return setTransition(transition);
	}

	private var _lastFrame:Float = 0;
	private var _frameTime:Statistic;
	private var _transition:Transition;
	private var _scene:Scene;
	private var _scenes:List<Scene>;
#if lime
	private var _window:lime.ui.Window;
#end

}
