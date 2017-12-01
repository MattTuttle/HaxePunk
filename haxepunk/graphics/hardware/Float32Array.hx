package haxepunk.graphics.hardware;

#if lime

typedef Float32Array = lime.utils.Float32Array;

#elseif nme

typedef Float32Array = haxepunk.backend.nme.Float32Array;

#else

typedef Float32Array = haxepunk.backend.generic.Float32Array;

#end
