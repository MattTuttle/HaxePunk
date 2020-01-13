package haxepunk.backend.generic;

#if (lime || nme)

typedef Sound = flash.media.Sound;

#else
interface Sound
{

}
#end
