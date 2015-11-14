import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.masks.*;
import haxepunk.inputs.*;

class MouseTrail extends haxepunk.scene.Entity
{

	public function new()
	{
		super();
		graphic = trail = new Spline("assets/lime.png", new Rectangle(101, 40, 310, 310));
		trail.maxPoints = 30;
	}

	override public function update(window:Window)
	{
		var width = 30,
			change = width / trail.maxPoints;
		var mouse = scene.camera.screenToCamera(window.input.mouse.position);
		trail.addPoint(mouse, width);
		trail.setThickness(function(i) { return i * change; });
	}

	private var trail:Spline;
}

class Main extends Engine
{
	override public function ready(window:Window)
	{
		var scene = window.scene;
		var camera = scene.camera;
		camera.x = -camera.halfWidth;
		camera.y = -camera.halfHeight;
		// camera.zoom = 0.5;

		var image = new Image("assets/lime.png");
		image.centerOrigin();
		scene.addGraphic(image);

		scene.add(new MouseTrail());

		window.console.enabled = true;

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
