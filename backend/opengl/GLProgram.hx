package backend.opengl;

#if hlsdl
typedef GLProgram = sdl.GL.Program;
#elseif js
typedef GLProgram = js.html.webgl.Program;
#else
typedef GLProgram = Null<UInt>;
#end
