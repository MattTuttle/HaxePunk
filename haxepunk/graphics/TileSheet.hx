package haxepunk.graphics;

import haxe.ds.IntMap;
import haxepunk.math.*;

class TileSheet
{

	public var tileWidth(default, null):Int;
	public var tileHeight(default, null):Int;
	public var material(default, null):Material;

    public function new(texture:Texture, tileWidth:Int, tileHeight:Int, ?tileSpacingWidth:Int=0, ?tileSpacingHeight:Int=0)
    {
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		var tilesInRow = Std.int(texture.width / tileWidth);
		var tilesInColumn = Std.int(texture.height / tileHeight);
		var totalTiles = tilesInRow * tilesInColumn;
		_tileRects = new IntMap<Rectangle>();
		for (tile in 0...totalTiles)
		{
			var tileX = (tile % tilesInRow) * tileWidth,
				tileY = Std.int(tile / tilesInRow) * tileHeight;
			_tileRects.set(tile, new Rectangle(tileX, tileY, tileWidth, tileHeight));
		}

		material = new Material();
		material.firstPass.addTexture(texture);
    }

	public function getTileRect(tile:Int):Rectangle
	{
		return _tileRects.get(tile);
	}

	private var _tileRects:IntMap<Rectangle>;
}
