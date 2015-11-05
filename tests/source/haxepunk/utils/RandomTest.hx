package haxepunk.utils;

import haxepunk.math.Math;

class RandomTest extends haxe.unit.TestCase
{

	public function testChoose()
	{
		Random.seed = 152435;
		var choices = ["apple", "banana", "orange"];
		var result = Random.choose(choices);
		assertEquals("apple", result);
		result = Random.choose(choices);
		assertEquals("orange", result);
	}

	public function testShuffle()
	{
		Random.seed = 7528463;
		var fruit = ["apple", "banana", "orange", "grape", "peach", "avocado"];
		var result = Random.shuffle(fruit);
		assertEquals("grape", result[0]);
		assertEquals("banana", result[4]);
	}

	public function testInt()
	{
		Random.seed = 583284;
		assertEquals(1213319600, Random.int());
		assertEquals(8, Random.int(10));
		assertEquals(197, Random.int(400));
	}

	public function testFloat()
	{
		Random.seed = 274835;
		assertEquals(0.151, Math.roundTo(Random.float(), 3));
		assertEquals(4.512, Math.roundTo(Random.float(24), 3));
		assertEquals(0.788725, Math.roundTo(Random.float(), 6));
	}

	public function testColor()
	{
		Random.seed = 587472;
		var color = Random.color();
		assertEquals(0.598, Math.roundTo(color.r, 3));
		assertEquals(0.767, Math.roundTo(color.g, 3));
		assertEquals(0.97, Math.roundTo(color.b, 3));
		assertEquals(0.11, Math.roundTo(color.a, 3));
	}

	public function testBoolean()
	{
		Random.seed = 92475683;
		assertEquals(false, Random.bool());
		assertEquals(false, Random.bool());
		assertEquals(true, Random.bool());
		assertEquals(true, Random.bool(0.9));
		assertEquals(false, Random.bool(0.1));
	}

}
