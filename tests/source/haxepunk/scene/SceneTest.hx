package haxepunk.scene;

import haxepunk.Window;

class SceneTest extends haxe.unit.TestCase
{

	@:access(haxepunk.Window)
	public function testScene()
	{
		var w = new Window();
		var initialScene = w.scene;
		var scene1 = new Scene();
		var scene2 = new Scene();
		var scene3 = new Scene();


		w.pushScene(scene1);
		assertEquals(initialScene, w.scene);
		assertEquals(scene1, w.nextScene);

		w.pushScene(scene2);
		assertEquals(scene2, w.nextScene);
		assertEquals(3, w._scenes.length);

		w.replaceScene(scene3);
		assertEquals(3, w._scenes.length);
		assertEquals(scene3, w.nextScene);

		w.popScene();
		assertEquals(scene1, w.nextScene);

		w.popScene();
		assertEquals(initialScene, w.nextScene);

		w.popScene();
		assertEquals(initialScene, w.nextScene);
	}

}
