package haxepunk.backend.html5;

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
			audio.src = source;
			audio.oncanplay = function() {
				resolve(sfx);
			}
		});
	}
}
