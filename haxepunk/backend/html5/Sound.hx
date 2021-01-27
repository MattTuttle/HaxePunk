package haxepunk.backend.html5;

import js.html.SourceElement;
#if js

import js.lib.Promise;
import js.html.Audio;

@:forward
abstract Sound(Audio) to Audio from Audio
{
	function new(audio:Audio) this = audio;

	public static function loadFromURL(source:String):Promise<Sound>
	{
		var audio = new Audio();
		var sfx = new Sound(audio);
		return new Promise<Sound>(function(resolve, reject) {
			audio.preload = 'auto';
			var se:SourceElement = cast js.Browser.document.createElement("source");
			se.src = source;
			se.type = "audio/wav";
			audio.appendChild(se);
			audio.addEventListener('loadedmetadata', () -> {
				resolve(sfx);
			});
		});
	}
}

#end
