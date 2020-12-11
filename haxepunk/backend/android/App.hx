package haxepunk.backend.android;

@:native("javax.microedition.khronos.opengles.GL10") extern class GL10 {}
@:native("javax.microedition.khronos.egl.EGLConfig") extern class EGLConfig {}

@:native("android.opengl.GLSurfaceView$Renderer")
extern interface GLSurfaceRenderer
{
	public function onDrawFrame(gl:GL10):Void;
	public function onSurfaceCreated(gl:GL10, config:EGLConfig):Void;
	public function onSurfaceChanged(gl:GL10, width:Int, height:Int):Void;
}

class App implements haxepunk.App implements GLSurfaceRenderer
{
	/** Sets if the application window should be fullscreen or windowed */
	@:isVar public var fullscreen(get, set):Bool;
	function get_fullscreen():Bool { return false; }
	function set_fullscreen(value:Bool):Bool { return fullscreen = value; }

	public function new() {}

	@:access(haxepunk.Engine)
	public function onSurfaceCreated(gl:GL10, config:EGLConfig)
	{
		engine.renderer = new haxepunk.backend.opengl.GLRenderer();
		engine.checkScene();
		engine.init();
		engine._rate = 1000 / HXP.assignedFrameRate;
		engine._last = getTimeMillis();
	}

	public function onDrawFrame(gl:GL10)
	{
		engine.onUpdate();
		engine.onRender();
	}

	public function onSurfaceChanged(gl:GL10, width:Int, height:Int)
	{
		if (HXP.width == 0 || HXP.height == 0)
		{
			// set initial size
			HXP.width = width;
			HXP.height = height;
			HXP.screen.scaleMode.setBaseSize();
		}
		HXP.resize(width, height);
		engine.onResize.invoke();
	}

	public function init(engine:Engine):Void
	{
		this.engine = engine;
	}

	/** Get the time in milliseconds */
	public function getTimeMillis():Float
	{
		return haxe.Timer.stamp() * 1000;
	}

	/** The current memory usage in bytes. Used by console but could be left unimplemented. */
	public function getMemoryUse():Float { return 0; }

	// no mouse cursor, so do nothing
	public function showCursor():Void {}
	public function hideCursor():Void {}

	/** Returns the state of multi-touch support */
	public function multiTouchSupported():Bool { return false; }

	/** Returns the current horizontal mouse coordinate */
	public function getMouseX():Float { return 0;}
	/** Returns the current vertical mouse coordinate **/
	public function getMouseY():Float { return 0; }

	var engine:Engine;
}
