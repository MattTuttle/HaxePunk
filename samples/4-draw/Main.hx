import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;

class DrawGraphic extends Graphic
{

	public function new()
	{
		super();
		color = new Color();
	}

	override public function draw(batch:SpriteBatch, offset:Vector3)
	{
		color.fromInt(0xFF00FF);
		var x = 0;
		Draw.begin(batch);
		while (x < batch.renderer.window.width)
		{
			var nx = x + 25;
			Draw.line(x, 0, nx, 50, color);
			Draw.line(nx, 50, nx, 0, color);
			x = nx;
		}

		Draw.pixel(70, 70, color);

		color.fromInt(0x0055FF);
		Draw.line(350, 100, 250, 150, color, 10);

		color.fromInt(0xFF00FF);
		Draw.fillRect(15, 150, 150, 50, color);
		color.fromInt(0x0055FF);
		Draw.rect(15, 150, 150, 50, color, 3);
		Draw.end();
	}

	private var color:Color;

}

class Main extends Engine
{
	override public function ready(window:Window)
	{
		window.scene.addGraphic(new DrawGraphic());
	}
}
