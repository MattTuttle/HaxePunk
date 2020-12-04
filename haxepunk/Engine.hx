package haxepunk;

import haxepunk.Signal;
import haxepunk.debug.Console;
import haxepunk.ds.Maybe;
import haxepunk.input.Input;
import haxepunk.math.Random;
import haxepunk.math.Rectangle;
import haxepunk.utils.Draw;
import haxepunk.backend.generic.render.Renderer;

/**
 * Main game Sprite class, added to the Stage.
 * Manages the game loop.
 *
 * Your main class **needs** to extends this.
 */
#if !macro
@:autoBuild(haxepunk.assets.Preloader.build())
@:build(haxepunk.assets.Preloader.build())
#end
@:access(haxepunk.HXP)
class Engine
{
	public var console:Maybe<Console> = null;

	/**
	 * If the game should stop updating/rendering.
	 */
	public var paused:Bool = false;

	/**
	 * Cap on the elapsed time (default at 30 FPS). Raise this to allow for lower framerates (eg. 1 / 10).
	 */
	public var maxElapsed:Float = 0.0333;

	/**
	 * The max amount of frames that can be skipped in fixed framerate mode.
	 */
	public var maxFrameSkip:Int = 5;

	/**
	 * Invoked before the update cycle begins each frame.
	 */
	public var preUpdate:Signal0 = new Signal0();
	/**
	 * Invoked after update cycle.
	 */
	public var postUpdate:Signal0 = new Signal0();
	/**
	 * Invoked before rendering begins each frame.
	 */
	public var preRender:Signal0 = new Signal0();
	/**
	 * Invoked after rendering completes.
	 */
	public var postRender:Signal0 = new Signal0();
	/**
	 * Invoked after the screen is resized.
	 */
	public var onResize:Signal0 = new Signal0();
	/**
	 * Invoked when input is received.
	 */
	public var onInputPressed:Signals = new Signals();
	/**
	 * Invoked when input is received.
	 */
	public var onInputReleased:Signals = new Signals();
	/**
	 * Invoked after the scene is switched.
	 */
	public var onSceneSwitch:Signal0 = new Signal0();
	/**
	 * Invoked when the application is closed.
	 */
	public var onClose:Signal0 = new Signal0();

	/**
	 * The rendering method to use
	 */
	public var renderer(default, null):Renderer;

	/**
	 * Constructor. Defines startup information about your game.
	 * @param	width			The width of your game.
	 * @param	height			The height of your game.
	 * @param	frameRate		The game framerate, in frames per second.
	 * @param	fixed			If a fixed-framerate should be used.
	 */
	public function new(width:Int = 0, height:Int = 0, frameRate:Float = 60, fixed:Bool = false)
	{
		// global game properties
		HXP.bounds = new Rectangle(0, 0, width, height);
		HXP.assignedFrameRate = frameRate;
		HXP.fixed = fixed;

		// global game objects
		HXP.engine = this;

		// set width/height or default them to 1280x720
		HXP.width = width == 0 ? 1280 : width;
		HXP.height = height == 0 ? 720 : height;

		HXP.screen = new Screen();
		HXP.app = app = createApp();

		// miscellaneous startup stuff
		if (Random.randomSeed == 0) Random.randomizeSeed();

		HXP.entity = new Entity();
		HXP.lastTimeFlag = app.getTimeMillis();

		_frameList = new Array();

		_sceneIterator = new VisibleSceneIterator();

		loadDefaultAssets();
	}

	/**
	 * @private This should be the only place an App instance is created
	 */
	function createApp():App
	{
#if (doc || unit_test)
		return new haxepunk.backend.generic.App();
#elseif (lime || nme)
		HXP.audio = new haxepunk.backend.flash.AudioEngine();
		renderer = new haxepunk.backend.opengl.GLRenderer();
		#if lime
		return new haxepunk.backend.lime.App();
		#else
		return new haxepunk.backend.nme.App();
		#end
#elseif hlsdl
		HXP.audio = new haxepunk.backend.openal.AudioEngine();
		renderer = new haxepunk.backend.opengl.GLRenderer();
		return new haxepunk.backend.hl.App();
#elseif js
		renderer = new haxepunk.backend.opengl.GLRenderer();
		HXP.audio = new haxepunk.backend.html5.AudioEngine();
		return new haxepunk.backend.html5.App();
#else
		#error "Invalid target";
#end
	}

	@:preload(["assets/haxepunk/fonts", "font"])
	function loadDefaultAssets() {
		Log.debug("Default HaxePunk assets are loaded");
		app.init(this);
	}

	/**
	 * Override this, called after Engine has been added to the stage.
	 */
	public function init() {}

	/**
	 * Override this, called when game gains focus
	 */
	public function focusGained() {}

	/**
	 * Override this, called when game loses focus
	 */
	public function focusLost() {}

	/**
	 * Updates the game, updating the Scene and Entities.
	 */
	public function update()
	{
		if (HXP.needsResize)
		{
			HXP.resize(HXP.windowWidth, HXP.windowHeight);
		}

		_scene.updateLists();
		checkScene();

		preUpdate.invoke();
		_scene.preUpdate.invoke();

		if (HXP.tweener.active && HXP.tweener.hasTween) HXP.tweener.updateTweens(HXP.elapsed);
		if (_scene.active)
		{
			if (_scene.hasTween) _scene.updateTweens(HXP.elapsed);
			_scene.update();
		}
		_scene.updateLists(false);

		_scene.postUpdate.invoke();
		postUpdate.invoke();
	}

	/**
	 * Called from backend renderer. Any visible scene will have its draw commands rendered to OpenGL.
	 */
	@:dox(hide)
	public function onRender()
	{
		// timing stuff
		var t:Float = app.getTimeMillis();
		if (paused)
		{
			_frameLast = t; // continue updating frame timer
			if (!Console.enabled) return; // skip rendering if paused and console is not enabled
		}
		if (_frameLast == 0) _frameLast = Std.int(t);

		preRender.invoke();

		renderer.startFrame();
		for (scene in _sceneIterator.reset(this))
		{
			renderer.startScene(scene);
			HXP.renderingScene = scene;
			scene.render();
			for (commands in scene.batch)
			{
				renderer.render(commands);
			}
			renderer.flushScene(scene);
		}
		HXP.renderingScene = null;
		renderer.endFrame();

		postRender.invoke();

		// more timing stuff
		t = app.getTimeMillis();
		_frameListSum += (_frameList[_frameList.length] = Std.int(t - _frameLast));
		if (_frameList.length > 10) _frameListSum -= _frameList.shift();
		HXP.frameRate = 1000 / (_frameListSum / _frameList.length);
		_frameLast = t;
	}

	/** @private Framerate independent game loop. */
	@:dox(hide)
	public function onUpdate()
	{
		_time = app.getTimeMillis();

		// update timer
		var elapsed = (_time - _last) / 1000;
		if (HXP.fixed)
		{
			_elapsed += elapsed;
			HXP.elapsed = 1 / HXP.assignedFrameRate;
			if (_elapsed > HXP.elapsed * maxFrameSkip) _elapsed = HXP.elapsed * maxFrameSkip;
			while (_elapsed > HXP.elapsed)
			{
				_elapsed -= HXP.elapsed;
				step();
			}
		}
		else
		{
			HXP.elapsed = elapsed;
			if (HXP.elapsed > maxElapsed) HXP.elapsed = maxElapsed;
			HXP.elapsed *= HXP.rate;
			step();
		}
		_last = _time;
	}

	function step()
	{
		HXP.audio.update();
		// update input
		Input.update();

		// update loop
		if (!paused) update();

		// update console
		console.may(function(c) c.update());

		Input.postUpdate();
	}

	/** @private Switch scenes if they've changed. */
	inline function checkScene()
	{
		if (_scene != null && _scenes.length > 0 && _scenes[_scenes.length - 1] != _scene)
		{
			Log.debug("ending scene: " + Type.getClassName(Type.getClass(_scene)));
			_scene.end();
			_scene.updateLists(false);
			if (_scene.autoClear && _scene.hasTween) _scene.clearTweens();

			_scene = _scenes[_scenes.length - 1];

			onSceneSwitch.invoke();

			Log.debug("starting scene: " + Type.getClassName(Type.getClass(_scene)));
			_scene.assetCache.enable();
			_scene.updateLists();
			if (_scene.started) _scene.resume();
			else _scene.begin();
			_scene.started = true;
			_scene.updateLists(true);
		}
	}

	/**
	 * Push a scene onto the stack. It will not become active until the next update.
	 * @param value  The scene to push
	 * @since	2.5.3
	 */
	public function pushScene(value:Scene):Void
	{
		Log.debug("pushed scene: " + Type.getClassName(Type.getClass(_scene)));
		_scenes.push(value);
	}

	/**
	 * Pop a scene from the stack. The current scene will remain active until the next update.
	 * @since	2.5.3
	 */
	public function popScene():Maybe<Scene>
	{
		if (_scenes.length > 0)
		{
			Log.debug("popped scene: " + Type.getClassName(Type.getClass(_scene)));
			var scene = _scenes.pop();
			if (scene.assetCache.enabled)
			{
				scene.assetCache.dispose();
			}
			return scene;
		}
		return null;
	}

	/**
	 * The currently active Scene object. When you set this, the Scene is flagged
	 * to switch, but won't actually do so until the end of the current frame.
	 * The returned scene is the currently active scene, NOT the value you set it to.
	 */
	public var scene(get, set):Scene;
	inline function get_scene():Scene return _scene;
	function set_scene(value:Scene):Scene
	{
		if (_scene != value)
		{
			popScene();
			pushScene(value);
		}
		return _scene;
	}

	/** An iterator for all visible scenes */
	public var scenes(get, never):Iterator<Scene>;
	inline function get_scenes() return _sceneIterator.reset(this);

	var app:App;

	// Scene information.
	var _scene:Scene = new Scene();
	var _scenes:Array<Scene> = new Array<Scene>();

	// Timing information.
	var _delta:Float = 0;
	var _time:Float = 0;
	var _last:Float = 0;
	var _rate:Float = 0;
	var _skip:Float = 0;
	var _prev:Float = 0;
	var _elapsed:Float = 0;

	// FrameRate tracking.
	var _frameLast:Float = 0;
	var _frameListSum:Int = 0;
	var _frameList:Array<Int>;

	var _sceneIterator:VisibleSceneIterator;
}

private class VisibleSceneIterator
{
	public function new() {}

	public inline function hasNext():Bool
	{
		return scenes.length > 0;
	}

	public inline function next():Scene
	{
		return scenes.pop();
	}

	@:access(haxepunk.Engine)
	public function reset(engine:Engine):VisibleSceneIterator
	{
		HXP.clear(scenes);

		engine.console.may(function(console) {
			scenes.push(console);
		});

		var scene:Scene;
		var i = engine._scenes.length - 1;
		while (i >= 0)
		{
			scene = engine._scenes[i];
			if (scene.visible && scene.started)
			{
				scenes.push(scene);
			}
			// if this scene has a solid background, stop adding scenes
			if (scene.bgAlpha == 1) break;
			--i;
		}
		return this;
	}

	var scenes:Array<Scene> = [];
}
