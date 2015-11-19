import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import haxepunk.math.Vector3;

class StressTestScene extends Scene
{
	public function new(window:Window)
	{
		super();
		var material = new Material();
		material.firstPass.insertTexture(Assets.getTexture("assets/lime.png"));
		var num = Std.int(Math.random() * 50 + 150);
		num = 10000;

		var material = new Material();
		material.firstPass.insertTexture(Assets.getTexture("assets/character.png"));

		for (i in 0...num)
		{
			var sprite = new Spritemap(material, 32, 32);
			sprite.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 12);
			sprite.play("walk");
			sprite.centerOrigin();

			addGraphic(sprite,
				Std.int(Math.random() * -50),
				Math.random() * window.width,
				Math.random() * window.height);
		}

		fps = new Text("", 32);
		addGraphic(fps, 10);
	}

	override public function update(window:Window)
	{
		super.update(window);
		fps.text = "" + Std.int(window.fps);
	}

	private var fps:Text;

}

class StressTest extends Engine
{
	override public function ready(window:Window)
	{
		window.scene = new StressTestScene(window);
	}

}
