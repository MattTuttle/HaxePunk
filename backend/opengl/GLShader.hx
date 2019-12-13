package backend.opengl;

#if hlsdl
typedef GLShader = sdl.GL.Shader;
#else
typedef GLShader = UInt;
#end
