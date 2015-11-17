package haxepunk.utils;

using haxepunk.utils.ArrayUtils;

class DataStorageTest extends haxe.unit.TestCase
{

    public var storage:DataStorage;

    override public function setup()
    {
        storage = new DataStorage();
    }

    public function testJson()
    {
        storage.fromJson('{"bar":true,"foo":573}');
        assertEquals(573, storage.retrieve("foo"));
        assertEquals(true, storage.retrieve("bar"));
        storage.remove("foo");
        assertEquals('{"bar":true}', storage.toJson());
    }

    public function testMemory()
    {
        storage.store("foo", 3);
        assertEquals(3, storage.retrieve("foo"));
        storage.store("foo", "bar");
        assertEquals("bar", storage.retrieve("foo"));
        // don't overwrite
        storage.store("foo", 814.532, false);
        assertEquals("bar", storage.retrieve("foo"));
    }

    public function testDefault()
    {
        assertEquals(25.64, storage.retrieve("foo", 25.64));
        assertEquals("default", storage.retrieve("bar", "default"));
    }

}
