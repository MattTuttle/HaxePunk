package haxepunk.backend.linc;

#if linc_opengl

import haxe.io.BytesData;
import haxepunk.graphics.hardware.Float32Array;
import opengl.GL.*;

class GL
{
	public static inline var TEXTURE0:Int = GL_TEXTURE0;
	public static inline var ARRAY_BUFFER:Int = GL_ARRAY_BUFFER;
	public static inline var TEXTURE_2D:Int = GL_TEXTURE_2D;
	public static inline var TEXTURE_MIN_FILTER:Int = GL_TEXTURE_MIN_FILTER;
	public static inline var TEXTURE_MAG_FILTER:Int = GL_TEXTURE_MAG_FILTER;
	public static inline var TEXTURE_WRAP_S:Int = GL_TEXTURE_WRAP_S;
	public static inline var TEXTURE_WRAP_T:Int = GL_TEXTURE_WRAP_T;
	public static inline var LINEAR:Int = GL_LINEAR;
	public static inline var NEAREST:Int = GL_NEAREST;
	public static inline var FLOAT:Int = GL_FLOAT;
	public static inline var UNSIGNED_BYTE:Int = GL_UNSIGNED_BYTE;
	public static inline var FRAMEBUFFER:Int = GL_FRAMEBUFFER;
	public static inline var RGB:Int = GL_RGB;
	public static inline var RGBA:Int = GL_RGBA;
	public static inline var COMPILE_STATUS:Int = GL_COMPILE_STATUS;
	public static inline var LINK_STATUS:Int = GL_LINK_STATUS;
	public static inline var NO_ERROR:Int = GL_NO_ERROR;
	public static inline var COLOR_ATTACHMENT0:Int = GL_COLOR_ATTACHMENT0;
	public static inline var COLOR_BUFFER_BIT:Int = GL_COLOR_BUFFER_BIT;
	public static inline var DEPTH_BUFFER_BIT:Int = GL_DEPTH_BUFFER_BIT;
	public static inline var FUNC_ADD:Int = GL_FUNC_ADD;
	public static inline var FUNC_REVERSE_SUBTRACT:Int = GL_FUNC_REVERSE_SUBTRACT;
	public static inline var ONE:Int = GL_ONE;
	public static inline var ZERO:Int = GL_ZERO;
	public static inline var TRIANGLES:Int = GL_TRIANGLES;
	public static inline var DST_COLOR:Int = GL_DST_COLOR;
	public static inline var ONE_MINUS_SRC_ALPHA:Int = GL_ONE_MINUS_SRC_ALPHA;
	public static inline var ONE_MINUS_SRC_COLOR:Int = GL_ONE_MINUS_SRC_COLOR;
	public static inline var SCISSOR_TEST:Int = GL_SCISSOR_TEST;
	public static inline var DYNAMIC_DRAW:Int = GL_DYNAMIC_DRAW;
	public static inline var STATIC_DRAW:Int = GL_STATIC_DRAW;
	public static inline var CLAMP_TO_EDGE:Int = GL_CLAMP_TO_EDGE;
	public static inline var FRAGMENT_SHADER:Int = GL_FRAGMENT_SHADER;
	public static inline var VERTEX_SHADER:Int = GL_VERTEX_SHADER;

	static var ids:Array<Int> = [-1];

	public static inline function enable(cap:Int) glEnable(cap);
	public static inline function disable(cap:Int) glDisable(cap);
	public static inline function uniformMatrix4fv(location:Int, transpose:Bool, value:Float32Array)
	{
		untyped __cpp__("glUniformMatrix4fv({0}, {1}, {2}, (const GLfloat*)&({3}[0]))", location, 1, transpose, value.toBytesData());
	}
	public static inline function activeTexture(texture:Int) glActiveTexture(texture);
	public static inline function deleteTexture(texture:Int) glDeleteTextures(1, [texture]);
	public static function createTexture():Int {
		glGenTextures(1, ids);
		return ids[0];
	}
	public static function texImage2D(target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:BytesData)
	{
		if (pixels != null)
		{
			glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
		}
		else
		{
			untyped __cpp__("glTexImage2D({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 0)", target, level, internalformat, width, height, border, format, type);
		}
	}
	public static inline function framebufferTexture2D(target:Int, attachment:Int, textarget:Int, texture:Null<Int>, level:Int)
	{
		if (texture != null) glFramebufferTexture2D(target, attachment, textarget, texture, level);
	}
	public static inline function clearColor(r:Int, g:Int, b:Int, a:Int) glClearColor(r, g, b, a);
	public static inline function clear(mask:Int) glClear(mask);
	public static inline function scissor(x:Int, y:Int, w:Int, h:Int) glScissor(x, y, w, h);
	public static inline function texParameteri(target:Int, pname:Int, param:Int) glTexParameteri(target, pname, param);
	public static inline function createBuffer():Int {
		glGenBuffers(1, ids);
		return ids[0];
	}
	public static inline function bindTexture(target:Int, texture:Null<Int>) glBindTexture(target, texture == null ? 0 : texture);
	public static inline function bindBuffer(target:Int, buffer:Null<Int>) glBindBuffer(target, buffer == null ? 0 : buffer);
	public static inline function bindFramebuffer(target:Int, framebuffer:Null<Int>) if (framebuffer != null) glBindFramebuffer(target, framebuffer);
	public static inline function bufferData(target:Int, data:Float32Array, usage:Int)
	{
		glBufferData(target, data.length * Float32Array.BYTES_PER_ELEMENT, data, usage);
	}
	public static inline function bufferSubData(target:Int, offset:Int, data:Float32Array)
	{
		glBufferSubData(target, offset, data.length * Float32Array.BYTES_PER_ELEMENT, data);
	}
	public static function getShaderInfoLog(shader:Int):String
	{
		untyped __cpp__("char __val[512];");
		untyped __cpp__("glGetShaderInfoLog({0}, 512, NULL, __val)", shader);
		return untyped __cpp__("::String(__val)");
	}
	public static inline function getError():Int return glGetError();
	public static inline function getAttribLocation(program:Int, name:String):Int return glGetAttribLocation(program, name);
	public static inline function getUniformLocation(program:Int, name:String):Int return glGetUniformLocation(program, name);
	public static inline function uniform1f(location:Int, v0:Float) glUniform1f(location, v0);
	public static inline function uniform1i(location:Int, v0:Int) glUniform1i(location, v0);
	public static inline function uniform2f(location:Int, v0:Float, v1:Float) glUniform2f(location, v0, v1);
	public static inline function compileShader(shader:Int) glCompileShader(shader);
	public static inline function getShaderParameter(shader:Int, param:Int):Int
	{
		glGetShaderiv(shader, param, ids);
		return ids[0];
	}
	public static inline function getProgramParameter(program:Int, param:Int):Int
	{
		glGetProgramiv(program, param, ids);
		return ids[0];
	}
	public static inline function createShader(type:Int):Int return glCreateShader(type);
	public static inline function createProgram():Int return glCreateProgram();
	public static inline function createFramebuffer():Int {
		glGenFramebuffers(1, ids);
		return ids[0];
	}
	public static inline function shaderSource(shader:Int, source:String)
	{
		untyped __cpp__("const GLchar *shader_source = {0}", source);
		untyped __cpp__("glShaderSource({0}, 1, &shader_source, NULL)", shader);
	}
	public static inline function attachShader(program:Int, shader:Int) glAttachShader(program, shader);
	public static inline function linkProgram(program:Int) glLinkProgram(program);
	public static inline function useProgram(program:Null<Int>) if (program != null) glUseProgram(program);
	public static inline function enableVertexAttribArray(index:Int) glEnableVertexAttribArray(index);
	public static inline function disableVertexAttribArray(index:Int) glDisableVertexAttribArray(index);
	public static inline function vertexAttribPointer(index:Int, size:Int, type:Int, normalized:Bool, stride:Int, pointer:Int)
	{
		untyped __cpp__("glVertexAttribPointer({0}, {1}, {2}, {3}, {4}, (const void*)({5}))", index, size, type, normalized, stride, pointer);
	}
	public static inline function blendEquation(mode:Int) glBlendEquation(mode);
	public static inline function blendEquationSeparate(rgb:Int, alpha:Int) glBlendEquationSeparate(rgb, alpha);
	public static inline function blendFunc(sfactor:Int, dfactor:Int) glBlendFunc(sfactor, dfactor);
	public static inline function blendFuncSeparate(sRGB:Int, dRGB:Int, sAlpha:Int, dAlpha:Int) glBlendFuncSeparate(sRGB, dRGB, sAlpha, dAlpha);
	public static inline function drawArrays(mode:Int, first:Int, count:Int) glDrawArrays(mode, first, count);
}

#end
