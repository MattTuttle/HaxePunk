import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.masks.*;
import haxepunk.inputs.Mouse;

class TrailEntity extends haxepunk.scene.Entity
{

	public function new()
	{
		super();
		drawable = true; // must be set to allow draw
	}

	override public function update(elapsed:Float)
	{
		var maxPoints = 30,
			width = 30,
			change = width / maxPoints;
		points.push({
			position: new Vector3(Mouse.x, Mouse.y),
			width: width
		});
		if (points.length > maxPoints) points.shift();
		for (point in points)
		{
			point.width -= change;
		}
	}

	override public function draw()
	{
		Draw.begin();
		Draw.trail(points, color);
	}

	private var color = new Color(0, 255, 255, 1);
	private var points = new Array<haxepunk.graphics.Draw.TrailPoint>();
}

class Main extends Engine
{
	override public function ready()
	{
		super.ready();

		scene.add(new TrailEntity());

		haxepunk.debug.Console.enabled = true;

		scene.addMask(new Box(30, 30, -15, -15), 0, 300, 500);
		scene.addMask(new Box(50, 50), 0, 400, 500);
		scene.addMask(new Circle(300, 50, 50), 0, 500, 500);

		var poly = Polygon.createRegular(5);
		poly.angle = -90 * Math.RAD;
		scene.addMask(poly, 0, 200, 250);

		scene.addMask(Polygon.createRegular(8, 75), 0, 400, 200);

		poly = Polygon.createRegular(5, 50);
		poly.origin.x = poly.origin.y = 50;
		poly.angle = 90 * Math.RAD;
		scene.addMask(poly, 0, 50, 50);
	}

}
