import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;

class Main extends Engine
{
	@:preload(["assets/graphics", "graphics"])
	override public function init()
	{
		Console.enable();
		HXP.scene = new MainScene();
	}

	public static function main() { new Main(); }
}
