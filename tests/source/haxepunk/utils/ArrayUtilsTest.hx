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

}
