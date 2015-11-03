package haxepunk.scene;

@:access(haxepunk.scene.Scene)
class EntityTest extends haxe.unit.TestCase
{

	public function testNoScene()
	{
		var e = new Entity();
		assertEquals("player", e.group = "player");
		assertEquals(null, e.collide("player"));
	}

	public function testAddToScene()
	{
		var scene = new Scene();
		var e = new Entity();
		scene.add(e);
		scene.updateEntities();
		assertEquals(scene, e.scene);
	}

}
