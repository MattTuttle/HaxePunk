package backend.opengl;

#if hlsdl
typedef GLFramebuffer = sdl.GL.Framebuffer;
#elseif js
typedef GLFramebuffer = js.html.webgl.Framebuffer;
#else
typedef GLFramebuffer = Null<UInt>;
#end
