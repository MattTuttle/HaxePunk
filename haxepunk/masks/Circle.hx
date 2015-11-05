package haxepunk.masks;

import haxepunk.math.Vector3;

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

    override public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
		// TODO: draw a smoother circle with shaders?
		var sides = 24,
			angle = 0.0,
			angleStep = (Math.PI * 2) / sides,
			posX = origin.x + offset.x,
			posY = origin.y + offset.y,
			lastX = posX + Math.cos(angle) * radius,
			lastY = posX + Math.sin(angle) * radius,
			pointX:Float,
			pointY:Float;
		for (i in 0...sides)
		{
			angle += angleStep;
			pointX = posX + Math.cos(angle) * radius;
			pointY = posY + Math.sin(angle) * radius;
			haxepunk.graphics.Draw.line(lastX, lastY, pointX, pointY, color);
			lastX = pointX;
			lastY = pointY;
		}
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

	public function intersectsGrid(other:Grid):Bool
	{
		var entityDist = origin - other.origin;

		var minx:Int = Math.floor((entityDist.x - radius) / other.cellWidth),
			miny:Int = Math.floor((entityDist.y - radius) / other.cellHeight),
			maxx:Int = Math.ceil((entityDist.x + radius) / other.cellWidth),
			maxy:Int = Math.ceil((entityDist.y + radius) / other.cellHeight);

		if (minx < 0) minx = 0;
		if (miny < 0) miny = 0;
		if (maxx > other.columns) maxx = other.columns;
		if (maxy > other.rows)    maxy = other.rows;

		var box = new Box(other.cellWidth, other.cellHeight);
		box.y = other.y + miny * other.cellHeight;
		for (row in miny...maxy)
		{
			box.x = other.x + minx * other.cellWidth;
			for (column in minx...maxx)
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
