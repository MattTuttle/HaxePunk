import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;

class Main extends Engine
{

	override public function init()
	{
		HXP.app.assets.add("../../assets/graphics");
		HXP.app.assets.add("../../assets/font");
		HXP.app.assets.add("assets/graphics", "gfx");
		HXP.app.assets.add("assets/audio", "sfx");
		HXP.app.assets.add("assets/atlas");

		Console.enable();
		HXP.scene = new effects.GameScene();
	}

	public static function main() { new Main(); }

}
