import haxepunk.Engine;
import haxepunk.HXP;

class Main extends Engine
{

	override public function init()
	{
		HXP.app.assets.add("assets/graphics", "gfx");
		HXP.app.assets.add("assets/atlas", "atlas");

		HXP.scene = new scenes.GameScene();

		#if lime
		var fps = new openfl.display.FPS(10, 10, 0);
		var format = fps.defaultTextFormat;
		format.size = 20;
		fps.defaultTextFormat = format;
		flash.Lib.current.stage.addChild(fps);
		#end
	}

	public static function main() { new Main(); }

}
