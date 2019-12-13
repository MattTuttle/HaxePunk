package backend.opengl;

#if hlsdl
typedef GLUniformLocation = sdl.GL.Uniform;
#else
typedef GLUniformLocation = UInt;
#end
