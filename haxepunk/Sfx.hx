package haxepunk;

#if hl

typedef Sfx = haxepunk.backend.openal.Sfx;

#elseif openfl

typedef Sfx = haxepunk.backend.flash.Sfx;

#elseif js

typedef Sfx = haxepunk.backend.html5.Sfx;

#elseif unit_test

typedef Sfx = Dynamic;

#else

#error "Sfx type not defined"

#end
