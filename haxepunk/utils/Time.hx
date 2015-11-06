package haxepunk.utils;

/**
 *
 */
@:allow(haxepunk.Engine)
class Time
{
	/** Total time elasped in miliseconds since the game started. */
	public static var totalElapsed(default, null):Float = 0;

	/** Total time elasped in miliseconds since the last frame. */
	public static var elapsed(default, null):Float = 0;

	/** The amount of update frames since the game started */
	public static var frames(default, null):Int = 0;

	/** The current time in miliseconds. */
	public static var current(get, null):Float;
	private inline static function get_current():Float { return haxe.Timer.stamp(); }

	/** The timescale applied to Time.elapsed. */
	public static var scale:Float;

	public static var updateFrameTime(default, null):Float = 0;
	public static var renderFrameTime(default, null):Float = 0;

	public function new()
	{

	}

	/**
	 * Sets a named time flag.
	 */
	public function start():Void
	{
		flag = Time.current;
	}

	/*
	 * Returns the time (in miliseconds) since the time flag [name] was set and removes it.
	 */
	public function stop():Float
	{
		var time = flag;
		flag = -1;
		return time;
	}

	/*
	 * Returns the delta time (in miliseconds) of a previous measured interval using start() and stop().
	 */
	public function get():Float
	{
		return Time.current - flag;
	}

	private var flag:Float = -1;

}
