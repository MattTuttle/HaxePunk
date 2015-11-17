package haxepunk.graphics;

import haxepunk.scene.Camera;
import haxepunk.math.*;

abstract TilesheetSource(TileSheet) to TileSheet from TileSheet
{
	private function new(tilesheet:TileSheet) { this = tilesheet; }

	@:from static private function fromAsset(asset:String):TilesheetSource
	{
		var parts = asset.split("@");
		if (parts.length == 2)
		{
			var file = parts.shift();
			var coords = parts.shift().split("x");
			if (coords.length == 2)
			{
				var w = Std.parseInt(coords[0]);
				var h = Std.parseInt(coords[1]);
				var tilesheet = new TileSheet(Assets.getTexture(file), w, h);
				return new TilesheetSource(tilesheet);
			}
		}
		throw "Expected tilesheet with format '<asset>@<width>x<height>'";
	}
}

class Tilemap extends Graphic
{

	public var tilesheet:TileSheet;
	public var tint:Color;

	public function new(source:TilesheetSource, width:Int, height:Int)
	{
		super();

		this.tilesheet = source;
		this.tint = new Color(1, 1, 1, 1);

		var tileWidth = tilesheet.tileWidth;
		var tileHeight = tilesheet.tileHeight;
		// clamp width/height to a multiple of the tile size
		_width = width - (width % tileWidth);
		_height = height - (height % tileHeight);
		// determine number of columns and rows
		_columns = Std.int(_width / tileWidth);
		_rows = Std.int(_height / tileHeight);

		// fill map with the "empty" tile id
		_map = new Array<Int>();
		for (i in 0...(_rows * _columns))
		{
			_map[i] = -1;
		}
	}

	/**
	* Loads the Tilemap tile index data from a string.
	* The implicit array should not be bigger than the Tilemap.
	* @param data             The string data, which is a set of tile values separated by the columnDelimiter and rowDelimiter strings.
	* @param columnDelimiter  The string that separates each tile value on a row, default is ",".
	* @param rowDelimiter     The string that separates each row of tiles, default is "\n".
	*/
	public function fromString(data:String, columnDelimiter:String = ",", rowDelimiter:String = "\n"):Void
	{
		var rows:Array<String> = data.split(rowDelimiter),
			columns:Array<String>;
		for (y in 0...rows.length)
		{
			if (rows[y] == '') continue;
			columns = rows[y].split(columnDelimiter);
			for (x in 0...columns.length)
			{
				if (columns[x] == '') continue;
				setTile(x, y, Std.parseInt(columns[x]));
			}
		}
	}

	/**
	* Saves the Tilemap tile index data to a string.
	* @param columnDelimiter  The string that separates each tile value on a row, default is ",".
	* @param rowDelimiter     The string that separates each row of tiles, default is "\n".
	* @return  The string version of the array.
	*/
	public function toString(columnDelimiter:String = ",", rowDelimiter:String = "\n"):String
	{
		var s:String = '',
			x:Int, y:Int;
		for (y in 0..._rows)
		{
			for (x in 0..._columns)
			{
				s += Std.string(getTile(x, y));
				if (x != _columns - 1) s += columnDelimiter;
			}
			if (y != _rows - 1) s += rowDelimiter;
		}
		return s;
	}

	/**
	 * Gets the tile index at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	The tile index.
	 */
	public inline function getTile(column:Int, row:Int):Int
	{
		return _map[(row % _rows) * _columns + (column % _columns)];
	}

	/**
	 * Sets the index of the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	index		Tile index.
	 */
	public inline function setTile(column:Int, row:Int, index:Int = 0)
	{
		_map[(row % _rows) * _columns + (column % _columns)] = index;
	}

	/**
	 * Clears the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public inline function clearTile(column:Int, row:Int)
	{
		_map[(row % _rows) * _columns + (column % _columns)] = -1;
	}

	/**
	 * Sets a rectangular region of tiles to the index.
	 * @param	column		First tile column.
	 * @param	row			First tile row.
	 * @param	width		Width in tiles.
	 * @param	height		Height in tiles.
	 * @param	index		Tile index.
	 */
	public function setRect(column:Int, row:Int, width:Int = 1, height:Int = 1, index:Int = 0)
	{
		for (y in row...(row + height))
		{
			for (x in column...(column + width))
			{
				setTile(x, y, index);
			}
		}
	}

	/**
	 * Clears the rectangular region of tiles.
	 * @param column  First tile column.
	 * @param row     First tile row.
	 * @param width   Width in tiles.
	 * @param height  Height in tiles.
	 */
	public function clearRect(column:Int, row:Int, width:Int = 1, height:Int = 1)
	{
		for (y in row...(row + height))
		{
			for (x in column...(column + width))
			{
				clearTile(x, y);
			}
		}
	}

	/**
	 * Set the tiles from a 2D array.
	 * The array must be of the same size as the Tilemap.
	 *
	 * @param array  The array to load from.
	 */
	public function loadFrom2DArray(array:Array<Array<Int>>):Void
	{
		var data:Array<Int>;
		for (y in 0...array.length)
		{
			data = array[y];
			for (x in 0...data.length)
			{
				setTile(x, y, data[x]);
			}
		}
	}

	override public function draw(batch:SpriteBatch, offset:Vector3):Void
	{
		var scaledTileWidth = tilesheet.tileWidth * scale.x,
			scaledTileHeight = tilesheet.tileHeight * scale.y;
		material = tilesheet.material; // set to the current tilesheet material
		for (y in 0..._rows)
		{
			for (x in 0..._columns)
			{
				var tile = getTile(x, y);
				if (tile < 0) continue;
				var rect = tilesheet.getTileRect(tile);
				if (rect == null) continue;
				batch.draw(material, x * scaledTileWidth, y * scaledTileHeight,
					scaledTileWidth, scaledTileHeight,
					rect.x, rect.y, rect.width, rect.height,
					false, false, 0, 0, scale.x, scale.y, 0, tint);
			}
		}
	}

	// Tilemap information.
	private var _map:Array<Int>;
	private var _columns:Int;
	private var _rows:Int;

	private var _width:Int;
	private var _height:Int;

}
