package haxepunk.scene;

import haxepunk.Window;

class SceneTest extends haxe.unit.TestCase
{

	public function testScene()
	{
		var w = new Window();
		var initialScene = w.scene;
		var scene = new Scene();

		w.pushScene(scene);
		assertEquals(initialScene, w.scene);
		w.update(); // change takes place after update
		assertEquals(scene, w.scene);

		w.popScene();
		assertEquals(scene, w.scene);
		w.update(); // change takes place after update
		assertEquals(initialScene, w.scene);

		w.popScene();
		w.update();
		assertEquals(initialScene, w.scene);
	}

}
