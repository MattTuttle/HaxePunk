package haxepunk.masks;

import haxepunk.math.*;

class Polygon extends Mask
{

    /**
	 * Constructor.
	 * @param	points		Points of the polygon.
	 */
    public function new(points:Array<Vector3>, x:Float=0, y:Float=0)
    {
		super(x, y);
		setPoints(points);
    }

	/**
	 * Creates a regular polygon (edges of same length).
	 * @param	sides	The number of sides in the polygon.
	 * @param	radius	The distance that the vertices are at.
	 * @return	The polygon
	 */
	public static function createRegular(sides:Int = 3, radius:Float = 100):Polygon
	{
		if (sides < 3) throw "Polygon requires at least 3 sides.";

		var angle = 0.0;
		var angleStep = (Math.PI * 2) / sides;

		// loop through and generate each point
		var points = new Array<Vector3>();
		for (i in 0...sides)
		{
			points.push(new Vector3(
				Math.cos(angle) * radius,
				Math.sin(angle) * radius
			));
			angle += angleStep;
		}

		// return the polygon
		return new Polygon(points);
	}

	/**
	 * The angle of the polygon in radians
	 */
	public var angle(get, set):Float;
	private inline function get_angle():Float { return _angle; }
	private function set_angle(value:Float):Float
	{
		if (value != _angle)
		{
			rotate(value - _angle); // calculate delta
		}
		return value;
	}

	/**
	 * Rotate the polygon by a specific angle
	 * @param delta The angle in radians to rotate by
	 */
	private function rotate(delta:Float):Void
	{
		var vecAngle:Float, length:Float;
		_angle += delta;

		for (p in _points)
		{
			vecAngle = Math.atan2(p.y, p.x) + delta;
			length = p.length;

			p.x = Math.cos(vecAngle) * length;
			p.y = Math.sin(vecAngle) * length;
		}

		for (a in _axes)
		{
			vecAngle = Math.atan2(a.y, a.x) + delta;

			a.x = Math.cos(vecAngle);
			a.y = Math.sin(vecAngle);
		}

		calculateBounds();
	}

	public function setPoints(points:Array<Vector3>):Void
	{
		if (points == null || points.length < 3)
		{
			throw "Polygon requires at least 3 points";
		}

		_points = points;
		generateAxes();
		calculateBounds();
	}

    override public function debugDraw(offset:Vector3, color:haxepunk.graphics.Color):Void
	{
		var pos = origin + offset;
		var firstPoint = _points[0] + pos,
			lastPoint = firstPoint;
		for (i in 1..._points.length) {
			var point = _points[i] + pos;
			haxepunk.graphics.Draw.line(lastPoint.x, lastPoint.y, point.x, point.y, color);
			lastPoint = point;
		}
		haxepunk.graphics.Draw.line(lastPoint.x, lastPoint.y, firstPoint.x, firstPoint.y, color);
	}

	override public function intersectsPolygon(other:Polygon):Bool
	{
		return intersectsWithAxes(other, _axes) && intersectsWithAxes(other, other._axes);
	}

	private function calculateBounds()
	{
		var h = project(horizontal);
		var v = project(vertical);
		min = new Vector3(h.min, v.min);
		max = new Vector3(h.max, v.max);
	}

	private function intersectsWithAxes(other:Polygon, axes:Array<Vector3>)
	{
		var offset:Float, firstProj:Projection, secondProj:Projection;
		var dx = origin.x - other.origin.x,
			dy = origin.y - other.origin.y;
		// project other on this polygon axes
		// for a collision to be present all projections must overlap
		for (a in axes)
		{
			firstProj = project(a);
			secondProj = other.project(a);

			// shift the first info with the offset
			offset = dx * a.x + dy * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj))
			{
				return false;
			}
		}
		return true;
	}

	private function generateAxes():Void
	{
		_axes = new Array<Vector3>();

		var nPoints:Int = _points.length;
		var i:Int, j:Int;

		i = 0;
		j = nPoints - 1;
		while (i < nPoints)
		{
			var edge = _points[i] - _points[j];

			// get the axis which is perpendicular to the edge
			var temp = edge.y;
			edge.y = -edge.x;
			edge.x = temp;
			edge.normalize();

			_axes.push(edge);

			j = i;
			i++;
		}

		// remove duplicate axes
		i = _axes.length - 1;
		j = i - 1;
		while (i > 0)
		{
			// if the first vector is equal or similar to the second vector,
			// remove it from the list. (for example, [1, 1] and [-1, -1]
			// represent the same axis)
			if ((Math.abs(_axes[i].x - _axes[j].x) < EPSILON && Math.abs(_axes[i].y - _axes[j].y) < EPSILON)
				|| (Math.abs(_axes[j].x + _axes[i].x) < EPSILON && Math.abs(_axes[i].y + _axes[j].y) < EPSILON))	// first axis inverted
			{
				_axes.splice(i, 1);
				i--;
			}

			j--;
			if (j < 0)
			{
				i--;
				j = i - 1;
			}
		}
	}

	public function project(axis:Vector3):Projection
	{
		var min:Float = axis.dot(_points[0]),
			max:Float = min,
			current:Float;

		for (i in 1..._points.length)
		{
			current = axis.dot(_points[i]);

			if (current < min) min = current;
			else if (current > max) max = current;
		}
		return new Projection(min, max);
	}

	private var _angle:Float = 0;
	private var _axes:Array<Vector3>;
	private var _points:Array<Vector3>;

	private static var EPSILON = 0.000000001;	// used for axes comparison in removeDuplicateAxes

	public static var horizontal = new Vector3(1, 0);
	public static var vertical = new Vector3(0, 1);

}
