package haxepunk.backend.linc;

import haxepunk.graphics.hardware.Texture;

class GLInternal
{
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		if (textures.exists(texture))
		{
			GL.bindTexture(GL.TEXTURE_2D, textures.get(texture));
		}
		else
		{
			var image = cast(texture.image, BytesImageData);
			var type = image.components == 3 ? GL.RGB : GL.RGBA;
			var textureID = GL.createTexture();
			GL.bindTexture(GL.TEXTURE_2D, textureID);
			GL.texImage2D(GL.TEXTURE_2D, 0, type, image.width, image.height, 0, type, GL.UNSIGNED_BYTE, image.data);
			textures.set(texture, textureID);
		}
	}

	public static inline function invalid(object:UInt)
	{
		return object <= 0;
	}

	static var textures = new Map<Texture, Int>();
}
