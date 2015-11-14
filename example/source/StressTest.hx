import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import haxepunk.math.Vector3;

class StressTest extends Engine
{
	override public function ready(window:Window)
	{
		_window = window;
		var material = new Material();
		material.firstPass.insertTexture(Assets.getTexture("assets/lime.png"));
		var num = Std.int(Math.random() * 50 + 150);
		num = 10000;

		var material = new Material();
		material.firstPass.insertTexture(Assets.getTexture("assets/character.png"));

		var scene = window.scene;
		for (i in 0...num)
		{
			var sprite = new Spritemap(material, 32, 32);
			sprite.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 12);
			sprite.play("walk");
			sprite.centerOrigin();

			scene.addGraphic(sprite,
				Std.int(Math.random() * -50),
				Math.random() * window.width,
				Math.random() * window.height);
		}

		fps = new Text("", 32);
		scene.addGraphic(fps);
	}

	override public function update(deltaTime:Int)
	{
		super.update(deltaTime);
		fps.text = "" + Std.int(_window.fps);
	}

	private var fps:Text;
	private var _window:Window;

}
