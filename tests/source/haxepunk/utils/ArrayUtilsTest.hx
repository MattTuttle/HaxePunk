package haxepunk.utils;

using haxepunk.utils.ArrayUtils;

class ArrayUtilsTest extends haxe.unit.TestCase
{

    public function testPrevious()
    {
        var array = [24, 534, 19.5, 68.2];
        assertEquals(24.0, array.previous(534));
        assertEquals(68.2, array.previous(24));
        assertEquals(null, array.previous(24, false)); // no loop
        assertEquals(null, array.previous(746)); // does not exist
        assertEquals(null, [].previous("hi")); // empty
    }

    public function testNext()
    {
        var array = [24, 534, 19.5, 68.2];
        assertEquals(19.5, array.next(534));
        assertEquals(24.0, array.next(68.2));
        assertEquals(null, array.next(68.2, false)); // no loop
        assertEquals(null, array.next(415)); // does not exist
        assertEquals(null, [].next("hi")); // empty
    }

    public function testClear()
    {
        var array = [64, 35, 73, 10];
        array.clear();
        assertEquals(0, array.length);
    }

    public function testContains()
    {
        var array = ["foo", "bar", "baz"];
        assertTrue(array.contains("bar"));
        assertFalse(array.contains("hello"));
        assertTrue([2, 4, 6].contains(4));
    }

    public function testInsertSorted()
    {
        var array = [];
        var sort = function(a:Int, b:Int) { return a - b; }
        array.insertSortedKey(343, sort);
        assertEquals(1, array.length);

        array.insertSortedKey(6, sort);
        assertEquals(2, array.length);
        assertEquals(6, array[0]);
        assertEquals(343, array[1]);

        array.insertSortedKey(25, sort);
        array.insertSortedKey(734, sort);
        array.insertSortedKey(1, sort);
        array.insertSortedKey(867, sort);

        var result = [1,6,25,343,734,867];
        for (i in 0...result.length)
        {
            assertEquals(result[i], array[i]);
        }
    }

}
