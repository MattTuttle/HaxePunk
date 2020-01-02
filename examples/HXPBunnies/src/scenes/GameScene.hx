package scenes;

import haxepunk.graphics.Graphiclist;
import haxepunk.graphics.Image;
// import haxepunk.graphics.text.Text;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.graphics.tile.Backdrop;
import haxepunk.masks.Grid;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.Scene;
import entities.Bunny;

class GameScene extends Scene
{
	var backdrop:Backdrop;
	var pirate:Image;
	var atlas:TextureAtlas;
	var numBunnies:Int;

	var gravity:Float = 5;
	var incBunnies:Int = 100;
	var time:Float = 0;

	var bunnies:Array<BunnyImage>;
	var bunnyImage:BunnyImage;
	var bunny:Entity;
	var bunnyList:Graphiclist;

	// var overlayText:Text;

	public function new()
	{
		super();

		numBunnies = incBunnies;

		atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
	}

	override public function begin()
	{
		// background
		backdrop = new Backdrop(atlas.getRegion("grass.png"), true, true);
		addGraphic(backdrop);

		// bunnies
		bunnies = [];
		bunny = new Entity();
		bunnyList = new Graphiclist([]);
		bunny.graphic = bunnyList;
		add(bunny);

		// and some big pirate
		pirate = new Image(atlas.getRegion("pirate.png"));
		addGraphic(pirate);

#if openfl
		overlayText = new Text("numBunnies = " + numBunnies, 0, 0, 0, 0, { color:0x000000, size:30 } );
		overlayText.resizable = true;
		var overlay:Entity = new Entity(0, HXP.screen.height - 40, overlayText);
		add(overlay);
#end

		addBunnies(numBunnies);
	}

	function addBunnies(numToAdd:Int):Void
	{
		var image = atlas.getRegion("bunny.png");
		for (i in 0...(numToAdd))
		{
			bunnyImage = new BunnyImage(image);
			bunnyImage.x = HXP.width * Math.random();
			bunnyImage.y = HXP.height * Math.random();
			bunnyImage.velocity.x = 50 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
			bunnyImage.velocity.y = 50 * ((Math.random() * 5) - 2.5) * (Math.random() < 0.5 ? 1 : -1);
			bunnyImage.angle = 15 - Math.random() * 30;
			bunnyImage.angularVelocity = 30 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
			bunnyImage.scale = 0.3 + Math.random();
			bunnyList.add(bunnyImage);
			bunnies.push(bunnyImage);
		}

		numBunnies = bunnies.length;
#if openfl
		overlayText.text = "numBunnies = " + numBunnies;
#else
		trace("numBunnies = " + numBunnies);
#end
	}

	override public function update()
	{
		time += HXP.elapsed;
		pirate.x = Std.int((HXP.width - pirate.width) * (0.5 + 0.5 * Math.sin(time / 3)));
		pirate.y = Std.int(HXP.height - 1.3 * pirate.height + 70 - 30 * Math.sin(time * 10));

		if (Mouse.mousePressed)
		{
			addingBunnies = true;
		}
		if (Mouse.mouseReleased)
		{
			addingBunnies = false;
		}

		if (addingBunnies)
		{
			addBunnies(incBunnies);
		}

		super.update();
	}

	var addingBunnies:Bool = false;
}
