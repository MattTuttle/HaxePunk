import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;

class Main extends Engine
{

	@:preload(["assets/graphics", "gfx"],
		["assets/atlas", "atlas"],
		["assets/audio", "sfx"])
	override public function init()
	{
		Console.enable();
		HXP.scene = new effects.GameScene();
	}

	public static function main() { new Main(); }

}
