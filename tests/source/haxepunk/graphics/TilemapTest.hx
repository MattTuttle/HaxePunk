package haxepunk.graphics;

@:access(haxepunk.graphics.Tilemap)
class TilemapTest extends haxe.unit.TestCase
{

	@:access(haxepunk.graphics.Texture)
	override public function setup()
	{
		var texture = new Texture();
		texture.width = 16;
		texture.height = 24;
		_tilesheet = new TileSheet(texture, 8, 12);
		_tilemap = new Tilemap(_tilesheet, 18, 29);
	}

	public function testInit()
	{
		assertEquals(8, _tilesheet.tileWidth);
		assertEquals(12, _tilesheet.tileHeight);

		assertEquals(16, _tilemap._width);
		assertEquals(24, _tilemap._height);

		assertEquals(2, _tilemap._columns);
		assertEquals(2, _tilemap._rows);
	}

	public function testTileAccessors()
	{
		assertEquals(-1, _tilemap.getTile(1, 1));
		assertEquals(-1, _tilemap.getTile(500, 5));

		_tilemap.setTile(0, 0, 10);
		assertEquals(10, _tilemap.getTile(0, 0));

		_tilemap.clearTile(0, 0);
		assertEquals(-1, _tilemap.getTile(0, 0));
	}

	public function testSetRect()
	{
		_tilemap.setRect(0, 0, 1, 2, 2);
		_tilemap.setRect(1, 0, 1, 2, 1);
		assertEquals(2, _tilemap.getTile(0, 0));
		assertEquals(1, _tilemap.getTile(1, 0));
		assertEquals(2, _tilemap.getTile(0, 1));
		assertEquals(1, _tilemap.getTile(1, 1));

		_tilemap.clearRect(0, 0, 2, 1);
		assertEquals("-1,-1\n2,1", _tilemap.toString());
	}

	public function test2DArray()
	{
		_tilemap.loadFrom2DArray([[3, 1], [4, 2]]);
		assertEquals("3,1\n4,2", _tilemap.toString());
	}

	public function testStringLoad()
	{
		_tilemap.fromString("1, 2\n 3,1");
		assertEquals(2, _tilemap.getTile(1, 0));

		_tilemap.fromString("1:2|3:1", ":", "|");
		assertEquals(3, _tilemap.getTile(0, 1));
	}

	public function testStringSave()
	{
		var data = _tilemap.toString();
		assertEquals("-1,-1\n-1,-1", data);
		assertEquals("-1:-1|-1:-1", _tilemap.toString(":", "|"));
	}

	private var _tilesheet:TileSheet;
	private var _tilemap:Tilemap;

}
