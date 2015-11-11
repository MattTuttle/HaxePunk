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
	 * Binary insertion sort
	 * @param array    The array to insert into
	 * @param key      The key to insert
	 * @param compare  A comparison function to determine sort order
	 */
	public static function insertSortedKey<T>(array:Array<T>, key:T, compare:T->T->Int):Void
	{
		var result:Int = 0,
			mid:Int = 0,
			min:Int = 0,
			max:Int = array.length - 1;
		while (max >= min)
		{
			mid = min + Std.int((max - min) / 2);
			result = compare(array[mid], key);
			if (result > 0) max = mid - 1;
			else if (result < 0) min = mid + 1;
			else break;
		}

		array.insert(result > 0 ? mid : mid + 1, key);
	}

	/**
	 * Choose a random element from an array.
	 * @param array  The array to choose from.
	 * @return The chosen item. If the array is empty a null is returned.
	 */
	@:generic
	public static function choose<T>(array:Array<T>):Null<T>
	{
		return array.length == 0 ? null : array[Random.int(array.length)];
	}

	/**
	 * Shuffles the elements in the array.
	 * @param array  The Object to shuffle (an Array or Vector).
	 */
	public static function shuffle<T>(array:Array<T>):Void
	{
		var i:Int = array.length, j:Int, t:T;
		while (--i > 0)
		{
			t = array[i];
			array[i] = array[j = Random.int(i + 1)];
			array[j] = t;
		}
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
