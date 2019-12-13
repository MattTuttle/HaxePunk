package backend.opengl;

#if hlsdl
typedef GLFramebuffer = sdl.GL.Framebuffer;
#else
typedef GLFramebuffer = Null<UInt>;
#end
