package backend.opengl;

#if hlsdl
typedef GLTexture = sdl.GL.Texture;
#elseif js
typedef GLTexture = js.html.webgl.Texture;
#else
typedef GLTexture = UInt;
#end
