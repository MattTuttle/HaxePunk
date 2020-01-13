package haxepunk.backend.html5;

import haxepunk.Signal.Signal0;
import haxepunk.assets.AssetCache;
import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.backend.html5.Texture;

class Preloader extends Scene
{

	public var onLoad:Signal0 = new Signal0();

	public function new(assets:Array<String>) {
		super();
		for (path in assets)
		{
			preloadAsset(path);
		}
	}

	function preloadAsset(path:String)
	{
		needLoaded += 1;
		var extension = path.split(".").pop();
		if (extension == "jpg" || extension == "jpeg" || extension == "png")
		{
			Texture.loadFromURL(path).then(function(texture) {
				AssetCache.global.addTexture(path, texture);
				assetFinished();
			}, function(_) {
				assetFinished();
			});
		}
		else if (extension == "mp3" || extension == "ogg" || extension == "wav")
		{
			Sfx.loadFromURL(path).then(function(sfx) {
				AssetCache.global.addSound(path, sfx);
				assetFinished();
			}, function(_) {
				assetFinished();
			});
		}
		else
		{
			trace("nothing loading for " + path);
		}
	}

	function assetFinished()
	{
		needLoaded -= 1;
		if (needLoaded == 0) {
			onLoad.invoke();
		}
	}

	var needLoaded:Int = 0;
}
