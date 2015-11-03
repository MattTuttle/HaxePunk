package haxepunk.masks;

import haxepunk.math.Vector3;

class Circle implements Mask
{

    public var origin:Vector3;
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
        this.origin = new Vector3(x, y);
		this.min = new Vector3();
		this.max = new Vector3();
        this.radius = radius;
    }

	public var min(default, null):Vector3;
	public var max(default, null):Vector3;

    public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
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

	public function overlap(other:Mask):Vector3
	{
		if (Std.is(other, Circle)) return overlapCircle(cast other);
		if (Std.is(other, Box)) return overlapBox(cast other);
		return null;
	}

	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, Circle)) return intersectsCircle(cast other);
		if (Std.is(other, Box)) return intersectsBox(cast other);
		return false;
	}

	public function intersectsCircle(other:Circle):Bool
	{
		var dx = other.origin.x - origin.x,
			dy = other.origin.y - origin.y;
		return (dx * dx + dy * dy) <= Math.pow(radius + other.radius, 2);
	}

	public function intersectsBox(other:Box):Bool
	{
		var halfWidth = other.width * 0.5;
		var halfHeight = other.height * 0.5;

		var distanceX = Math.abs(origin.x - other.origin.x - halfWidth),
			distanceY = Math.abs(origin.y - other.origin.y - halfHeight);

		// the hitbox is too far away so return false
		if (distanceX > halfWidth + radius || distanceY > halfHeight + radius) return false;
		if (distanceX <= halfWidth || distanceY <= halfHeight) return true;

		return Math.pow(distanceX - halfWidth, 2) + Math.pow(distanceY - halfHeight, 2) <= radius * radius;
	}

	public function containsPoint(point:Vector3):Bool
	{
		return point.x >= origin.x - radius && point.x <= origin.x + radius &&
		 	point.y >= origin.y - radius && point.y <= origin.y + radius;
	}

	public function overlapBox(other:Box):Vector3
	{
		// TODO: finish this function
		return null;
	}

	public function overlapCircle(other:Circle):Vector3
	{
		// TODO: finish this function
		return null;
	}

}
