package haxepunk.graphics;

import haxepunk.graphics.Image;
import haxepunk.math.*;

/**
 * Draws a list of points as a spline
 * Useful for: rivers, roads, spaceship trails, etc...
 */
class Spline extends Image
{

	/**
	 * Sets the maximum number of points in the spline. If less than 0, it is infinite.
	 */
	public var maxPoints:Int = -1;

	/**
	 * The number of points currently in the spline.
	 */
	public var numPoints(get, never):Int;
	private inline function get_numPoints():Int { return _points.length; }

    public function new(source:ImageSource, ?clipRect:Rectangle)
    {
		super(source, clipRect);
		clear();
    }

	/**
	 * Removes all points from the spline.
	 */
	public function clear():Void
	{
		_points = new Array<Vector3>();
		_normals = new Array<Vector3>();
	}

	/**
	 * Set thickness of all points in the spline
	 * @param callback  A function to return the thickness value of every point in the spline. The first parameter is the index of the point.
	 */
	public function setThickness(callback:Int->Float):Void
	{
		for (i in 0..._normals.length)
		{
			_normals[i].normalize(callback(i) / 2);
		}
	}

	/**
	 * Add a point to the spline.
	 * @param point      The point to add.
	 * @param thickness  The thickness value of the spline at that point
	 */
	public function addPoint(point:Vector3, thickness:Float):Void
	{
		_points.push(point);

		// calculate normals
		var size = _points.length;
		if (size > 1)
		{
			for (i in (size - 2)...size)
			{
				var current = _points[i];
				var previous = (i > 0) ? _points[i-1] : current;
				var next = (i+1 < size) ? _points[i+1] : current;
				// create perpendicular normal vector
				var normal = (current - previous) + (next - current);
				normal.normalize(i+2 < size ? _normals[i].length : (thickness / 2));
				var tmp = -normal.x;
				normal.x = normal.y;
				normal.y = tmp;
				_normals[i] = normal;
			}
		}

		// remove first point
		if (maxPoints >= 0 && size > maxPoints)
		{
			_points.shift();
			_normals.shift();
		}
	}

	@:dox(hide)
    override public function draw(batch:SpriteBatch, offset:Vector3):Void
    {
        var r = tint.r,
			g = tint.g,
			b = tint.b,
			a = tint.a;

		batch.material = material;

		// must be calculated AFTER setting material since that can change the texture
		var u1 = clipRect.left * batch.inverseTexWidth,
			u2 = clipRect.right * batch.inverseTexWidth,
			v1 = clipRect.top * batch.inverseTexHeight,
			v2 = clipRect.bottom * batch.inverseTexHeight;

		// TODO: calculate uv coords from section of texture?
		var point:Vector3,
			normal:Vector3;
		for (i in 1..._points.length)
		{
			batch.addQuad();
			// previous
			point = _points[i-1];
			normal = _normals[i-1];
			batch.addVertex(offset.x + point.x + normal.x,
				offset.y + point.y + normal.y, u1, v2, r, g, b, a);
			batch.addVertex(offset.x + point.x - normal.x,
				offset.y + point.y - normal.y, u1, v1, r, g, b, a);
			// current
			point = _points[i];
			normal = _normals[i];
			batch.addVertex(offset.x + point.x - normal.x,
				offset.y + point.y - normal.y, u2, v1, r, g, b, a);
			batch.addVertex(offset.x + point.x + normal.x,
				offset.y + point.y + normal.y, u2, v2, r, g, b, a);
		}
    }

	private var _points:Array<Vector3>;
	private var _normals:Array<Vector3>;

}
