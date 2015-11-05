import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.masks.*;
import haxepunk.inputs.Mouse;

class MouseTrail extends haxepunk.scene.Entity
{

	public function new()
	{
		super();
		graphic = trail = new Trail("assets/lime.png");
		trail.maxPoints = 30;
		trail.tint.fromInt(0xFF00FFFF);
	}

	override public function update(elapsed:Float)
	{
		var width = 30,
			change = width / trail.maxPoints;
		trail.addPoint(new Vector3(Mouse.x, Mouse.y), width);
		var width = 0.0;
		for (i in 0...trail.numPoints)
		{
			trail.setThickness(i, width);
			width += change;
		}
	}

	private var trail:Trail;
}

class Main extends Engine
{
	override public function ready()
	{
		super.ready();

		scene.add(new MouseTrail());

		/*haxepunk.debug.Console.enabled = true;

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
		scene.addMask(poly, 0, 50, 50);*/
	}

}
