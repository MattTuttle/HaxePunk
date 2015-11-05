package haxepunk.masks;

import haxepunk.graphics.*;
import haxepunk.math.*;

class Circle extends Mask
{

    public var radius(default, set):Float;
	private function set_radius(value:Float):Float
	{
		min.x = min.y = -value;
		max.x = max.y = value;
		return radius = value;
	}
    public var diameter(get, never):Float;
    private inline function get_diameter():Float { return radius * 2; }

    /**
	 * Constructor.
	 * @param	radius		Radius of the circle.
	 * @param	x			X position of the circle.
	 * @param	y			Y position of the circle.
	 */
    public function new(radius:Float=0, x:Float=0, y:Float=0)
    {
		super(x, y);
        this.radius = radius;
		register(Circle, intersectsCircle, separateCircle);
		register(Box, intersectsBox);
		register(Grid, intersectsGrid);
    }

    override public function debugDraw(offset:Vector3, color:Color):Void
	{
		Draw.circle(origin.x + offset.x, origin.y + offset.y, radius, color);
	}

	override public function containsPoint(point:Vector3):Bool
	{
		var dx = origin.x - point.x,
			dy = origin.y - point.y;
		return (dx * dx + dy * dy) <= radius * radius;
	}

	public function intersectsCircle(other:Circle):Bool
	{
		var dx = other.origin.x - origin.x,
			dy = other.origin.y - origin.y,
            r = other.radius + radius;
		return (dx * dx + dy * dy) <= r * r;
	}

    public function separateCircle(other:Circle):Null<Vector3>
    {
		var delta = other.origin - origin,
            r = other.radius + radius,
			separation = Math.sqrt(r * r) - delta.length;
		// if the length of radius is longer than the distance between origins, there is an overlap
		if (separation >= 0)
		{
			delta.normalize(separation);
			return delta;
		}
		return null;
    }

	public function intersectsBox(other:Box):Bool
	{
		var delta = other.origin - origin;

		// the hitbox is too far away so return false
		if (Math.abs(delta.x) > other.halfWidth + radius ||
			Math.abs(delta.y) > other.halfHeight + radius) return false;
		if (Math.abs(delta.x) <= other.halfWidth ||
			Math.abs(delta.y) <= other.halfHeight) return true;

		var x = delta.x - other.halfWidth,
			y = delta.y - other.halfHeight;

		return x*x + y*y <= radius * radius;
	}

	override public function project(axis:Vector3):Projection
	{
		var dot = origin.dot(axis);
		return new Projection(dot - radius, dot + radius);
	}

	public function intersectsGrid(other:Grid):Bool
	{
		// get position of circle on the grid
		var gridPos = origin - other.origin;

		var minX:Int = Math.floor((gridPos.x - radius) / other.cellWidth),
			minY:Int = Math.floor((gridPos.y - radius) / other.cellHeight),
			maxX:Int = Math.ceil((gridPos.x + radius) / other.cellWidth),
			maxY:Int = Math.ceil((gridPos.y + radius) / other.cellHeight);

		if (minX < 0) minX = 0;
		if (minY < 0) minY = 0;
		if (maxX > other.columns) maxX = other.columns;
		if (maxY > other.rows)    maxY = other.rows;

		// use an axis-aligned box to determine intersections for each cell
		var box = new Box(other.cellWidth, other.cellHeight);
		// calculate starting positions for grid cells
		// grid position + cell position + half cell width
		var startX = other.x + minX * other.cellWidth + other.cellWidth / 2;
		box.y = other.y + minY * other.cellHeight + other.cellHeight / 2;
		for (row in minY...maxY)
		{
			box.x = startX;
			for (column in minX...maxX)
			{
				if (other.getCell(column, row) && intersectsBox(box))
				{
					return true;
				}
				box.x += other.cellWidth;
			}
			box.y += other.cellHeight;
		}

		return false;
	}

}
