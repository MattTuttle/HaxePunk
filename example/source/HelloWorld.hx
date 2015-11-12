import haxepunk.*;
import haxepunk.graphics.*;

class HelloWorld extends Engine
{
	override public function ready(window:Window)
	{
		window.backgroundColor = new Color(0.9, 0.9, 0.9, 1.0);
		var text = new Text("Hello world", 32);
		text.color.fromInt(0);
		text.centerOrigin();
		window.scene.addGraphic(text, 0, window.width / 2, window.height / 2);
	}
}
