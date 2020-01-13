package haxepunk;

#if hl

typedef Sfx = backend.openal.Sfx;

#elseif openfl

typedef Sfx = backend.flash.Sfx;

#elseif js

typedef Sfx = backend.html5.Sfx;

#elseif unit_test

typedef Sfx = Dynamic;

#else

#error "Sfx type not defined"

#end
