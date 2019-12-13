package backend.opengl;

#if hlsdl
typedef GLProgram = sdl.GL.Program;
#else
typedef GLProgram = Null<UInt>;
#end
