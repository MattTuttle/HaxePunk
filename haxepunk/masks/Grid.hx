package haxepunk.masks;

import haxepunk.graphics.*;
import haxepunk.math.*;

class Grid extends Mask
{
    public var columns(default, null):Int;

    public var rows(default, null):Int;

    public var cellWidth(default, null):Float;

    public var cellHeight(default, null):Float;

    public function new(columns:Int, rows:Int, cellWidth:Float=0, cellHeight:Float=0, x:Float=0, y:Float=0)
    {
        super(x, y);
        this.columns = columns;
        this.rows = rows;
        this.cellWidth = cellWidth;
        this.cellHeight = cellHeight;

        // calculate bounds
        max.x = columns * cellWidth;
        max.y = rows * cellHeight;

        // initialize grid
        _grid = new Array<Bool>();
        for (i in 0...columns*rows)
        {
            _grid[i] = false;
        }

        register(Box, intersectsBox);
    }

    public function setRect(column:Int, row:Int, width:Int, height:Int, solid:Bool=true):Void
    {
        for (y in row...(row + height))
		{
			for (x in column...(column + width))
			{
				setCell(x, y, solid);
			}
		}
    }

    public function setCell(column:Int, row:Int, solid:Bool=true):Void
    {
        _grid[getIndex(column, row)] = solid;
    }

    public function getCell(column:Int, row:Int):Bool
    {
        return _grid[getIndex(column, row)];
    }

    private inline function getIndex(column:Int, row:Int):Int
    {
        return (row % rows) * columns + (column % columns);
    }

    public function intersectsBox(other:Box):Bool
    {
        var pos = other.origin - origin;
		var pointX = Std.int((pos.x + other.width  - 1) / cellWidth) + 1;
		var pointY = Std.int((pos.y + other.height - 1) / cellHeight) + 1;
		var rectX  = Std.int(pos.x / cellWidth);
		var rectY  = Std.int(pos.y / cellHeight);

		for (dy in rectY...pointY)
		{
			for (dx in rectX...pointX)
			{
				if (getCell(dx, dy))
				{
					return true;
				}
			}
		}
		return false;
    }

    override public function debugDraw(offset:Vector3, color:Color):Void
    {
        var pos = offset + origin;
        Draw.grid(pos.x, pos.y, max.x, max.y, columns, rows, color);
        for (y in 0...rows)
        {
            for (x in 0...columns)
            {
                if (getCell(x, y))
                {
                    Draw.fillRect(pos.x, pos.y, cellWidth, cellHeight, color);
                }
                pos.x += cellWidth;
            }
            pos.x = offset.x + origin.x;
            pos.y += cellHeight;
        }
    }

    private var _grid:Array<Bool>;

}
