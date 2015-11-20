import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;

class HelloWorld extends Engine
{
	override public function ready(window:Window)
	{
		var scene = new Scene();
		var text = new Text("Hello world", 32);
		text.color.fromInt(0);
		text.centerOrigin();
		scene.addGraphic(text, 0, window.width / 2, window.height / 2);

		window.scene.camera.clearColor = new Color().fromInt(0x333333);
		window.replaceScene(scene, new Transition(5));
	}
}
