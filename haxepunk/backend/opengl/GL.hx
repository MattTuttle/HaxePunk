package haxepunk.backend.opengl;

#if (doc || unit_test)

typedef GLBuffer = Null<UInt>;
typedef GLFramebuffer = Null<UInt>;
typedef GLProgram = Null<UInt>;
typedef GLShader = Null<UInt>;
typedef GLTexture = Null<UInt>;
typedef GLUniformLocation = Null<UInt>;

class GL
{
	public static inline var NO_ERROR:Int = 0;
	public static inline var TEXTURE0:Int = 0;
	public static inline var TEXTURE1:Int = 0;
	public static inline var TEXTURE2:Int = 0;
	public static inline var ARRAY_BUFFER:Int = 0;
	public static inline var TEXTURE_2D:Int = 0;
	public static inline var TEXTURE_MIN_FILTER:Int = 0;
	public static inline var TEXTURE_MAG_FILTER:Int = 0;
	public static inline var TEXTURE_WRAP_S:Int = 0;
	public static inline var TEXTURE_WRAP_T:Int = 0;
	public static inline var LINEAR:Int = 0;
	public static inline var NEAREST:Int = 0;
	public static inline var FLOAT:Int = 0;
	public static inline var UNSIGNED_BYTE:Int = 0;
	public static inline var FRAMEBUFFER:Int = 0;
	public static inline var RGBA:Int = 0;
	public static inline var BGRA:Int = 0;
	public static inline var COLOR_ATTACHMENT0:Int = 0;
	public static inline var COLOR_BUFFER_BIT:Int = 0;
	public static inline var DEPTH_BUFFER_BIT:Int = 0;
	public static inline var FUNC_ADD:Int = 0;
	public static inline var FUNC_REVERSE_SUBTRACT:Int = 0;
	public static inline var ONE:Int = 0;
	public static inline var ZERO:Int = 0;
	public static inline var TRIANGLES:Int = 0;
	public static inline var DST_COLOR:Int = 0;
	public static inline var ONE_MINUS_SRC_ALPHA:Int = 0;
	public static inline var ONE_MINUS_SRC_COLOR:Int = 0;
	public static inline var SCISSOR_TEST:Int = 0;
	public static inline var DYNAMIC_DRAW:Int = 0;
	public static inline var STATIC_DRAW:Int = 0;
	public static inline var CLAMP_TO_EDGE:Int = 0;
	public static inline var FRAGMENT_SHADER:Int = 0;
	public static inline var VERTEX_SHADER:Int = 0;
	public static inline var MIRRORED_REPEAT:Int = 0;

	public static function enable(_) {}
	public static function disable(_) {}
	public static function uniformMatrix4fv(_, _, _, ?_, ?_) {}
	public static function activeTexture(_) {}
	public static function deleteTexture(_) {}
	public static function createTexture():GLTexture { return 0; }
	public static function texImage2D(_, _, _, _, _, _, _, _, _) {}
	public static function framebufferTexture2D(_, _, _, _, _) {}
	public static function clearColor(_, _, _, _) {}
	public static function clear(_) {}
	public static function scissor(_, _, _, _) {}
	public static function texParameteri(_, _, _) {}
	public static function createBuffer():GLBuffer { return 0; }
	public static function bindBuffer(_, _) {}
	public static function bindFramebuffer(_, _) {}
	public static function bufferData(_, _, _, ?_) {}
	public static function bufferSubData(_, _, _, ?_, ?_) {}
	public static function getError():Int { return 0; }
	public static function getUniformLocation(_, _):GLUniformLocation { return 0; }
	public static function uniform1f(_, _) {}
	public static function uniform1i(_, _) {}
	public static function uniform2f(_, _, _) {}
	public static function uniform4fv(_, _, _, _) {}
	public static function compileShader(_) {}
	public static function createShader(_):GLShader { return 0; }
	public static function createProgram():GLProgram { return 0; }
	public static function createFramebuffer():GLFramebuffer { return 0; }
	public static function deleteFramebuffer(_) {}
	public static function shaderSource(_, _) {}
	public static function attachShader(_, _) {}
	public static function linkProgram(_) {}
	public static function useProgram(_) {}
	public static function enableVertexAttribArray(_) {}
	public static function disableVertexAttribArray(_) {}
	public static function getAttribLocation(_, _):Int { return 0; }
	public static function vertexAttribPointer(_, _, _, _, _, _) {}
	public static function blendEquation(_) {}
	public static function blendEquationSeparate(_, _) {}
	public static function blendFunc(_, _) {}
	public static function blendFuncSeparate(_, _, _, _) {}
	public static function drawArrays(_, _, _) {}
	public static function bindTexture(_, _) {}
}

#elseif hlsdl

typedef GLBuffer = sdl.GL.Buffer;
typedef GLFramebuffer = sdl.GL.Framebuffer;
typedef GLProgram = sdl.GL.Program;
typedef GLShader = sdl.GL.Shader;
typedef GLTexture = sdl.GL.Texture;
typedef GLUniformLocation = sdl.GL.Uniform;
typedef GL = sdl.GL;

#elseif lime

typedef GL = lime.graphics.opengl.GL;
typedef GLBuffer = lime.graphics.opengl.GLBuffer;
typedef GLFramebuffer = lime.graphics.opengl.GLFramebuffer;
typedef GLProgram = lime.graphics.opengl.GLProgram;
typedef GLShader = lime.graphics.opengl.GLShader;
typedef GLTexture = lime.graphics.opengl.GLTexture;
typedef GLUniformLocation = lime.graphics.opengl.GLUniformLocation;

#elseif nme

typedef GL = nme.gl.GL;
typedef GLBuffer = flash.gl.GLBuffer;
typedef GLFramebuffer = flash.gl.GLFramebuffer;
typedef GLProgram = nme.gl.GLProgram;
typedef GLShader = nme.gl.GLShader;
typedef GLTexture = nme.gl.GLTexture;
typedef GLUniformLocation = nme.gl.GLUniformLocation;

#elseif js

typedef GLBuffer = js.html.webgl.Buffer;
typedef GLFramebuffer = js.html.webgl.Framebuffer;
typedef GLProgram = js.html.webgl.Program;
typedef GLShader = js.html.webgl.Shader;
typedef GLTexture = js.html.webgl.Texture;
typedef GLUniformLocation = js.html.webgl.UniformLocation;
typedef GL = js.html.webgl.GL;

#else

#error "Invalid GL target"

#end

#if (lime || !js)
typedef _GL = GL;
#end
