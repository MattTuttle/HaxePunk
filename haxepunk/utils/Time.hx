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

	/** The current time in milliseconds. */
	public static var now(get, null):Float;
	private inline static function get_now():Float { return haxe.Timer.stamp() * 1000; }

	/** The timescale applied to Time.elapsed. */
	public static var scale:Float;

	/**
	 * Returns the delta time (in miliseconds)
	 * @param time The start time to determine the delta.
	 */
	public inline static function since(time:Float):Float
	{
		return Time.now - time;
	}

}
