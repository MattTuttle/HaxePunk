package haxepunk.masks;

class Grid extends Mask
{
    public var columns(default, set):Int;
    private function set_columns(value:Int):Int {
        if (value != columns)
        {
            columns = value;
            calculateBounds();
        }
        return value;
    }

    public var rows(default, set):Int;
    private function set_rows(value:Int):Int {
        if (value != rows)
        {
            rows = value;
            calculateBounds();
        }
        return value;
    }

    public var cellWidth(default, set):Float;
    private function set_cellWidth(value:Float):Float {
        if (value != cellWidth)
        {
            cellWidth = value;
            calculateBounds();
        }
        return value;
    }

    public var cellHeight(default, set):Float;
    private function set_cellHeight(value:Float):Float {
        if (value != cellHeight)
        {
            cellHeight = value;
            calculateBounds();
        }
        return value;
    }

    public function new(columns:Int, rows:Int, cellWidth:Float, cellHeight:Float, x:Float=0, y:Float=0)
    {
        super(x, y);
        this.columns = columns;
        this.rows = rows;
        this.cellWidth = cellWidth;
        this.cellHeight = cellHeight;

        _grid = new Array<Bool>();
    }

    public function getTile(column:Int, row:Int):Bool
    {
        var index = row * columns + column;
        if (index > _grid.length) return false;
        return _grid[index];
    }

    private inline function calculateBounds():Void
    {
        max.x = columns * cellWidth;
        max.y = rows * cellHeight;
    }

    private var _grid:Array<Bool>;

}
