package haxepunk.graphics.hardware.opengl;

#if lime

typedef GLInternal = haxepunk.backend.lime.GLInternal;

#elseif nme

typedef GLInternal = haxepunk.backend.nme.GLInternal;

#elseif linc_opengl

typedef GLInternal = haxepunk.backend.linc.GLInternal;

#else

class GLInternal
{
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture) {}

	public static inline function invalid(object:UInt)
	{
		return object == 0;
	}
}

#end
