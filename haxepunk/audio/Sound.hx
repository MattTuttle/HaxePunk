package haxepunk.audio;

import haxepunk.assets.AssetCache;

abstract SoundSource(Sound) to Sound from Sound
{
	public function new(sound:Sound) this = sound;

	@:from public static function fromString(id:String)
	{
		return new SoundSource(AssetCache.global.getSound(id));
	}
}

#if (lime || nme)

typedef Sound = flash.media.Sound;

#elseif js

typedef Sound = haxepunk.backend.html5.Sound;

#else

typedef Sound = haxepunk.backend.openal.formats.AudioData;

#else

#error "No Sound class is defined"

#end
