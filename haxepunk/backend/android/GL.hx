package haxepunk.backend.android;

import java.nio.Buffer;
import java.nio.IntBuffer;
import java.nio.FloatBuffer;

@:native("android.opengl.GLES20")
extern class GL {
    @:native("GL_COLOR_BUFFER_BIT") public static var COLOR_BUFFER_BIT:Int;
    @:native("GL_DEPTH_BUFFER_BIT") public static var DEPTH_BUFFER_BIT:Int;
    @:native("GL_SCISSOR_TEST") public static var SCISSOR_TEST:Int;
    @:native("GL_FRAMEBUFFER") public static var FRAMEBUFFER:Int;
    @:native("GL_ARRAY_BUFFER") public static var ARRAY_BUFFER:Int;
    @:native("GL_STATIC_DRAW") public static var STATIC_DRAW:Int;
    @:native("GL_DYNAMIC_DRAW") public static var DYNAMIC_DRAW:Int;
    @:native("GL_FLOAT") public static var FLOAT:Int;
    @:native("GL_UNSIGNED_BYTE") public static var UNSIGNED_BYTE:Int;
    @:native("GL_TRIANGLES") public static var TRIANGLES:Int;
    @:native("GL_TEXTURE_2D") public static var TEXTURE_2D:Int;
    @:native("GL_TEXTURE0") public static var TEXTURE0:Int;
    @:native("GL_COLOR_ATTACHMENT0") public static var COLOR_ATTACHMENT0:Int;
    @:native("GL_NO_ERROR") public static var NO_ERROR:Int;
    @:native("GL_NEAREST") public static var NEAREST:Int;
    @:native("GL_LINEAR") public static var LINEAR:Int;
    @:native("GL_TEXTURE_MIN_FILTER") public static var TEXTURE_MIN_FILTER:Int;
    @:native("GL_TEXTURE_MAG_FILTER") public static var TEXTURE_MAG_FILTER:Int;
    @:native("GL_TEXTURE_WRAP_T") public static var TEXTURE_WRAP_T:Int;
    @:native("GL_TEXTURE_WRAP_S") public static var TEXTURE_WRAP_S:Int;
    @:native("GL_CLAMP_TO_EDGE") public static var CLAMP_TO_EDGE:Int;
    @:native("GL_VERTEX_SHADER") public static var VERTEX_SHADER:Int;
    @:native("GL_FRAGMENT_SHADER") public static var FRAGMENT_SHADER:Int;
    @:native("GL_RGBA") public static var RGBA:Int;
    @:native("GL_ONE") public static var ONE:Int;
    @:native("GL_ONE_MINUS_SRC_ALPHA") public static var ONE_MINUS_SRC_ALPHA:Int;
    @:native("GL_ONE_MINUS_SRC_COLOR") public static var ONE_MINUS_SRC_COLOR:Int;
    @:native("GL_ZERO") public static var ZERO:Int;
    @:native("GL_DST_COLOR") public static var DST_COLOR:Int;
    @:native("GL_FUNC_ADD") public static var FUNC_ADD:Int;
    @:native("GL_FUNC_REVERSE_SUBTRACT") public static var FUNC_REVERSE_SUBTRACT:Int;

    @:native("glClear") public static function clear(flags:Int):Void;
    @:native("glClearColor") public static function clearColor(r:Single, g:Single, b:Single, a:Single):Void;
    @:native("glViewport") public static function viewport(x:Int, y:Int, width:Int, height:Int):Void;
	@:native("glBindTexture") public static function bindTexture(target:Int, texture:Int):Void;
    @:native("glActiveTexture") public static function activeTexture(texture:Int):Void;
	@:native("glTexParameteri") public static function texParameteri(target:Int, pname:Int, param:Int):Void;
	@:native("glVertexAttribPointer") public static function vertexAttribPointer(index:Int, size:Int, type:Int, normalized:Bool, stride:Int, ptr:Int):Void;
	@:native("glDrawArrays") public static function drawArrays(mode:Int, first:Int, count:Int):Void;
	@:native("glEnable") public static function enable(cap:Int):Void;
	@:native("glDisable") public static function disable(cap:Int):Void;
    @:native("glUniform1i") public static function uniform1i(location:Int, x:Int):Void;
    @:native("glUniform1f") public static function uniform1f(location:Int, x:Single):Void;
    @:native("glUniform2f") public static function uniform2f(location:Int, x:Single, y:Single):Void;
    @:native("glBlendEquation") public static function blendEquation(mode:Int):Void;
    @:native("glBlendEquationSeparate") public static function blendEquationSeparate(modeRGB:Int, modeAlpha:Int):Void;
    @:native("glBlendFunc") public static function blendFunc(sfactor:Int, dfactor:Int):Void;
    @:native("glBlendFuncSeparate") public static function blendFuncSeparate(srcRGB:Int, dstRGB:Int, srcAlpha:Int, dstAlpha:Int):Void;
    @:native("glGenFramebuffers") public static function genFramebuffers(n:Int, framebuffers:IntBuffer):Void;
    @:native("glDeleteFramebuffer") public static function deleteFramebuffer(framebuffer:Int):Void;
    @:native("glBindFramebuffer") public static function bindFramebuffer(location:Int, framebuffer:Int):Void;
    @:native("glCreateProgram") public static function createProgram():Int;
    @:native("glUseProgram") public static function useProgram(program:Int):Void;
    @:native("glLinkProgram") public static function linkProgram(program:Int):Void;
    @:native("glCreateShader") public static function createShader(type:Int):Int;
    @:native("glCompileShader") public static function compileShader(shader:Int):Void;
    @:native("glAttachShader") public static function attachShader(program:Int, shader:Int):Void;
    @:native("glShaderSource") public static function shaderSource(shader:Int, string:String):Void;
    @:native("glGenBuffers") public static function genBuffers(n:Int, buffers:IntBuffer):Void;
    @:native("glGenTextures") public static function genTextures(n:Int, textures:IntBuffer):Void;
    @:native("glDeleteTexture") public static function deleteTexture(texture:Int):Void;
    @:native("glBindBuffer") public static function bindBuffer(target:Int, buffer:Int):Void;
    @:native("glBufferData") public static function bufferData(target:Int, size:Int, data:Buffer, usage:Int):Void;
	@:native("glBufferSubData") public static function bufferSubData(target:Int, offset:Int, size:Int, data:Buffer):Void;
    @:native("glScissor") public static function scissor(x:Int, y:Int, width:Int, height:Int):Void;
    @:native("glGetError") public static function getError():Int;
    @:native("glGetUniformLocation") public static function getUniformLocation(program:Int, name:String):Int;
    @:native("glGetAttribLocation") public static function getAttribLocation(program:Int, name:String):Int;
	@:native("glTexImage2D") public static function texImage2D(target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:Buffer):Void;
	@:native("glFramebufferTexture2D") public static function framebufferTexture2D(target:Int, attachment:Int, textarget:Int, texture:Int, level:Int):Void;
    @:native("glEnableVertexAttribArray") public static function enableVertexAttribArray(index:Int):Void;
    @:native("glDisableVertexAttribArray") public static function disableVertexAttribArray(index:Int):Void;
	@:native("glUniformMatrix4fv") public static function uniformMatrix4fv(location:Int, count:Int, transpose:Bool, value:FloatBuffer):Void;

    public static inline function createBuffer():Int {
        var a = IntBuffer.allocate(1);
        genBuffers(1, a);
        return a.get(0);
    }

    public static inline function createTexture():Int {
        var a = IntBuffer.allocate(1);
        genTextures(1, a);
        return a.get(0);
    }

    public static inline function createFramebuffer():Int {
        var a = IntBuffer.allocate(1);
        genFramebuffers(1, a);
        return a.get(0);
    }
}