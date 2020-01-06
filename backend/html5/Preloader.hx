package backend.html5;

import haxepunk.Signal.Signal0;
import haxepunk.assets.AssetCache;
import haxepunk.HXP;
import haxepunk.Scene;
import backend.html5.Texture;

class Preloader extends Scene
{

	public var onLoad:Signal0 = new Signal0();

	public function new(assets:Array<String>) {
		super();
		for (asset in assets)
		{
			preloadTexture(asset);
		}
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
			onLoad.invoke();
		}
	}

	var needLoaded:Int = 0;
}
