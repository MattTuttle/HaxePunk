package haxepunk.scene;

import haxepunk.Engine;

class SceneTest extends haxe.unit.TestCase
{

	public function testInitialScene()
	{
		var scene = new Scene();
		var e = new Engine(scene);
		assertEquals(scene, Engine.scene);
	}

	public function testScene()
	{
		var e = new Engine();
		var initialScene = Engine.scene;
		var scene = new Scene();

		Engine.pushScene(scene);
		assertEquals(initialScene, Engine.scene);
		e.update(0); // change takes place after update
		assertEquals(scene, Engine.scene);

		Engine.popScene();
		assertEquals(scene, Engine.scene);
		e.update(0); // change takes place after update
		assertEquals(initialScene, Engine.scene);

		Engine.popScene();
		e.update(0);
		assertEquals(initialScene, Engine.scene);
	}

}
