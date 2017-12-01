import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.graphics.Image;

class Main extends Engine
{
	public override function init()
	{
		HXP.screen.color = 0x111111;

		var scene = new Scene();
		scene.addGraphic(new Image("assets/block.png"));
		pushScene(scene);
	}

	public static function main() { new Main(); }
}
