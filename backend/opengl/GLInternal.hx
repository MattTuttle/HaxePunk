package backend.opengl;

import haxepunk.graphics.hardware.Texture;

class GLInternal
{
	@:allow(backend.opengl.GLUtils)
	static function bindTexture(texture:Texture) {}

	public static inline function invalid(object:UInt)
	{
		return object == 0;
	}
}
