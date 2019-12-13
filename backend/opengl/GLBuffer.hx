package backend.opengl;

#if hlsdl
typedef GLBuffer = sdl.GL.Buffer;
#else
typedef GLBuffer = Null<UInt>;
#end
