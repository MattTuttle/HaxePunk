package haxepunk.graphics;

import haxepunk.graphics.Image;
import haxepunk.math.*;

class Trail extends Graphic
{

	public var tint:Color;

	public var maxPoints:Int = 10;

	public var numPoints(get, never):Int;
	private inline function get_numPoints():Int { return _points.length; }

    public function new(source:ImageSource)
    {
		super();
		tint = new Color();
		_points = new Array<Vector3>();
		_normals = new Array<Vector3>();

#if !unit_test
		this.material = source;
#end
    }

	public function setThickness(index:Int, thickness:Float):Void
	{
		if (index >= 0 && index < _normals.length)
		{
			_normals[index].normalize(thickness / 2);
		}
	}

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
		if (size > maxPoints)
		{
			_points.shift();
			_normals.shift();
		}
	}

	@:access(haxepunk.graphics.SpriteBatch)
    override public function draw(offset:Vector3):Void
    {
        var r = tint.r,
			g = tint.g,
			b = tint.b,
			a = tint.a;

		SpriteBatch.material = material;

		// TODO: calculate uv coords from section of texture?
		var point:Vector3,
			normal:Vector3;
		for (i in 1..._points.length)
		{
			SpriteBatch.addQuad();
			// previous
			point = _points[i-1];
			normal = _normals[i-1];
			SpriteBatch.addVertex(offset.x + point.x + normal.x,
				offset.y + point.y + normal.y, 0, 1, r, g, b, a);
			SpriteBatch.addVertex(offset.x + point.x - normal.x,
				offset.y + point.y - normal.y, 0, 0, r, g, b, a);
			// current
			point = _points[i];
			normal = _normals[i];
			SpriteBatch.addVertex(offset.x + point.x - normal.x,
				offset.y + point.y - normal.y, 1, 0, r, g, b, a);
			SpriteBatch.addVertex(offset.x + point.x + normal.x,
				offset.y + point.y + normal.y, 1, 1, r, g, b, a);
		}
    }

	private var _points:Array<Vector3>;
	private var _normals:Array<Vector3>;

}
