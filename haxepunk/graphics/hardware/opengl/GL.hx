package haxepunk.graphics.hardware.opengl;

#if lime
typedef GL = lime.graphics.opengl.GL;
#elseif nme
typedef GL = flash.gl.GL;
#elseif linc_opengl
typedef GL = haxepunk.backend.linc.GL;
#else
typedef GL = haxepunk.backend.generic.GL;
#end
