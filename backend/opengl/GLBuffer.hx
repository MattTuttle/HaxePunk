package backend.opengl;

#if hlsdl
typedef GLBuffer = sdl.GL.Buffer;
#elseif js
typedef GLBuffer = js.html.webgl.Buffer;
#else
typedef GLBuffer = Null<UInt>;
#end
