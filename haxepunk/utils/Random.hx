package haxepunk.utils;

import haxepunk.math.Math;
import haxepunk.graphics.Color;

/**
 * Pseudo-random number generator.
 */
class Random
{
	/** The seed of the generator. Using the same seed will result in the same sequence of values. */
	public static var seed(default, set):Int = 0;
	private static function set_seed(value:Int):Int
	{
		return seed = Std.int(Math.clamp(value, 1.0, Math.INT_MAX - 1));
	}

	/**
	 * Randomizes the pseudo-random seed using Math.random().
	 */
	public static function randomizeSeed():Void
	{
		seed = Std.int(Math.INT_MAX * Math.random());
	}

	/**
	 * Returns a pseudo-random Int.
	 * @param	amount  The returned Int will always be 0 <= Int < amount. Default=INT_MAX
	 * @return	The Int.
	 */
	public static function int(amount:Int=Math.INT_MAX):Int
	{
		seed = Std.int((seed * 16807.0) % Math.INT_MAX);
		return Std.int((seed / Math.INT_MAX) * amount);
	}

	/**
	 * A pseudo-random Float.
	 * @param   amount  The returned Float will always be 0 <= Float < amount. Default=1.0
	 * @return  The Float.
	 */
	public static function float(amount:Float=1):Float
	{
		seed = Std.int((seed * 16807.0) % Math.INT_MAX);
		return seed / Math.INT_MAX * amount;
	}

	/**
	 * Returns a pseudo-random boolean.
	 * @param probability  The probability of a true value, where 0 <= Float < 1. Default=0.5
	 */
	public static function bool(probability:Float=0.5):Bool
	{
		return Random.float() < probability;
	}

	/**
	 * Returns a pseudo-random color.
	 */
	public static function color():Color
	{
		return new Color(float(), float(), float(), float());
	}

	/**
	 * Choose a random element from an array.
	 * @param values The array to choose from.
	 * @return The chosen item.
	 */
	@:generic
	public static function choose<T>(values:Array<T>):T
	{
		if (values.length == 0)
		{
			throw "Can't choose a random element on an empty array";
		}

		return values[int(values.length)];
	}

	/**
	 * Shuffle the array. Returns a new copy and doesn't modify the array passed in argument.
	 */
	@:generic
	public static function shuffle<T>(array:Array<T>):Array<T>
	{
		var copy = array.copy();
		var i:Int = copy.length, j:Int, t:T;
		while (--i > 0)
		{
			t = copy[i];
			copy[i] = copy[j = int(i + 1)];
			copy[j] = t;
		}
		return copy;
	}
}
