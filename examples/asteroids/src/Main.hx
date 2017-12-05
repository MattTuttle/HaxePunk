import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;

class Main extends Engine
{

	override public function init()
	{
		HXP.app.assets.add("assets/graphics");
		HXP.app.assets.add("assets/shaders");
		HXP.app.assets.add("assets/audio");
		HXP.app.assets.add("../../assets/graphics");
		HXP.app.assets.add("../../assets/font");

		Console.enable();
		HXP.scene = new MainScene();
	}

	public static function main() { new Main(); }

}
