package backend.opengl;

#if hlsdl
typedef GLUniformLocation = sdl.GL.Uniform;
#elseif js
typedef GLUniformLocation = js.html.webgl.UniformLocation;
#else
typedef GLUniformLocation = UInt;
#end
