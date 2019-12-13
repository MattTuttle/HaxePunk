package backend.opengl;

#if hlsdl
typedef GLTexture = sdl.GL.Texture;
#else
typedef GLTexture = UInt;
#end
