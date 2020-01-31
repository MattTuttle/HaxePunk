import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;

class Main extends Engine
{
	@:preload("assets/fonts", "assets/graphics")
	override public function init()
	{
		Console.enable();
		HXP.scene = new MainScene();
	}

	static function main() new Main(800, 480);
}
