package backend.opengl;

#if hlsdl
typedef GLShader = sdl.GL.Shader;
#elseif js
typedef GLShader = js.html.webgl.Shader;
#else
typedef GLShader = UInt;
#end
