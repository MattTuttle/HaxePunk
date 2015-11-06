package haxepunk.utils;

/**
 * Utilities for Array objects
 * Used with "using"
 */
class ArrayUtils
{
	/**
	 * Returns the previous element in the array relative to the current element.
	 */
	@:generic
	public static function previous<T>(array:Array<T>, current:T, loop:Bool=true):Null<T>
	{
		if (array == null || array.length == 0)
		{
			// array is empty
			return null;
		}

		var index = array.indexOf(current);
		if (index == -1)
		{
			// item not found in array
			return null;
		}
		index -= 1;
		// bounds check
		if (index < 0)
		{
			if (loop)
			{
				index = array.length - 1;
			}
			else
			{
				// no previous value since current was the first item in the array
				return null;
			}
		}
		return array[index];
	}

	/**
	 * Returns the next element in the array relative to the current element.
	 */
	@:generic
	public static function next<T>(array:Array<T>, current:T, loop:Bool=true):Null<T>
	{
		if (array == null || array.length == 0)
		{
			// array is empty
			return null;
		}

		var index = array.indexOf(current);
		if (index == -1)
		{
			// item not found in array
			return null;
		}
		index += 1;
		// bounds check
		if (index >= array.length)
		{
			if (loop)
			{
				index = 0;
			}
			else
			{
				// no previous value since current was the first item in the array
				return null;
			}
		}
		return array[index];
	}

	/**
	 * Empties an array.
	 */
	@:generic
	public static function clear<T>(array:Array<T>):Void
	{
		#if (cpp || php)
		array.splice(0, array.length);
		#else
		untyped array.length = 0;
		#end
	}

	/**
	 * Checks if the array contains the specified element using standard equality.
	 */
	@:generic
	public static function contains<T>(array:Array<T>, element:T):Bool
	{
		return array.indexOf(element) != -1;
	}

}
