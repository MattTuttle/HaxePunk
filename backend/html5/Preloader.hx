package backend.html5;

import haxepunk.assets.AssetCache;
import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import backend.html5.Texture;

class Preloader extends Scene
{

	var needLoaded:Int = 0;
	var readyScene:Class<Scene>;

	public function new(assets:Array<String>, readyScene:Class<Scene>) {
		super();
		for (asset in assets)
		{
			preloadTexture(asset);
		}
		this.readyScene = readyScene;
	}

	function preloadTexture(url:String)
	{
		needLoaded += 1;
		Texture.loadFromURL(url).then(function(texture) {
			AssetCache.global.addTexture(url, texture);
			finishLoad();
		}, function(_) {
			finishLoad();
		});
	}

	function finishLoad()
	{
		needLoaded -= 1;
		if (needLoaded == 0) {
			HXP.scene = Type.createInstance(readyScene, []);
		}
	}
}
