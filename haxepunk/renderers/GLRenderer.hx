package haxepunk.renderers;

#if !flash

import haxe.io.Bytes;
import haxepunk.graphics.Color;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import lime.graphics.*;
import lime.graphics.opengl.*;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.utils.UInt8Array;

class GLRenderer
{

	public static var window:Window;

	public static function clear(color:Color):Void
	{
		GL.clearColor(color.r, color.g, color.b, color.a);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	public static inline function setViewport(viewport:Rectangle):Void
	{
		GL.viewport(Std.int(viewport.x), Std.int(viewport.y), Std.int(viewport.width), Std.int(viewport.height));
	}

	public static inline function attribute(program:ShaderProgram, a:String):Int
	{
		return GL.getAttribLocation(program, a);
	}

	public static inline function uniform(program:ShaderProgram, u:String):Location
	{
		return GL.getUniformLocation(program, u);
	}

	public static inline function present():Void
	{
		_totalRenderCalls += _renderCalls;
		_renderCalls = 0;
		#if js
		GL.finish();
		#end
	}

	public static inline function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		if (_activeState.blendSource == source && _activeState.blendDestination == destination) return;

		if (source == ONE && destination == ZERO)
		{
			GL.disable(GL.BLEND);
		}
		else
		{
			GL.blendFunc(BLEND[source], BLEND[destination]);
			GL.enable(GL.BLEND);
		}

		_activeState.blendSource = source;
		_activeState.blendDestination = destination;
	}

	public static inline function setCullMode(mode:CullMode):Void
	{
		if (mode == NONE)
		{
			GL.disable(GL.CULL_FACE);
		}
		else
		{
			GL.enable(GL.CULL_FACE);
			GL.cullFace(CULL[mode]);
		}
	}

	public static function capture(rect:Rectangle):Image
	{
		var width = Std.int(rect.width),
			height = Std.int(rect.height);
		var bytesPerRow = width * 4;
		var pixels = new UInt8Array(height * bytesPerRow);
		GL.readPixels(Std.int(rect.x), Std.int(rect.y), width, height, GL.RGBA, GL.UNSIGNED_BYTE, pixels);
		// flip result vertically
		var tmp, row = 0, flippedRow = height * bytesPerRow;
		for (y in 0...Std.int(rect.height / 2))
		{
			flippedRow -= bytesPerRow; // start at beginning of row
			for (x in 0...bytesPerRow)
			{
				tmp = pixels[row];
				pixels[row++] = pixels[flippedRow];
				pixels[flippedRow++] = tmp;
			}
			flippedRow -= bytesPerRow;
		}
		return new Image(new ImageBuffer(pixels, width, height), 0, 0, width, height);
	}

	public static inline function createTextureFromBytes(bytes:Bytes, width:Int, height:Int, bitsPerPixel:Int=32):NativeTexture
	{
		var format = switch (bitsPerPixel) {
			case 8: GL.ALPHA;
			case 24: GL.RGB;
			case 32: GL.RGBA;
			default: throw "Unsupported bits per pixel: " + bitsPerPixel;
		};
		var texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.texImage2D(GL.TEXTURE_2D, 0, format, width, height, 0, format, GL.UNSIGNED_BYTE, UInt8Array.fromBytes(bytes));
		return texture;
	}

	public static inline function deleteTexture(texture:NativeTexture):Void
	{
		GL.deleteTexture(texture);
	}

	public static inline function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		if (_activeState.texture == texture) return;

		GL.activeTexture(GL.TEXTURE0 + sampler);
		GL.bindTexture(GL.TEXTURE_2D, texture);
		_activeState.texture = texture;
	}

	public static function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var program:ShaderProgram = GL.createProgram();

		if (compileShader(program, vertex, GL.VERTEX_SHADER) == null) return null;
		if (compileShader(program, fragment, GL.FRAGMENT_SHADER) == null) return null;
		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			trace(GL.getProgramInfoLog(program));
			trace("VALIDATE_STATUS: " + GL.getProgramParameter(program, GL.VALIDATE_STATUS));
			trace("ERROR: " + GL.getError());
			return null;
		}

		return program;
	}

	public static inline function bindProgram(?program:ShaderProgram):Void
	{
		if (_activeState.program != program)
		{
			GL.useProgram(program);
			_activeState.program = program;
		}
	}

	public static inline function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		GL.uniformMatrix4fv(loc, false, matrix.native);
	}

	public static inline function setVector3(loc:Location, vec:Vector3):Void
	{
		GL.uniform3f(loc, vec.x, vec.y, vec.z);
	}

	public static inline function setColor(loc:Location, color:Color):Void
	{
		GL.uniform4f(loc, color.r, color.g, color.b, color.a);
	}

	public static inline function setFloat(loc:Location, value:Float):Void
	{
		GL.uniform1f(loc, value);
	}

	public static inline function setAttribute(a:Int, offset:Int, num:Int):Void
	{
		GL.vertexAttribPointer(a, num, GL.FLOAT, false, _activeState.buffer.stride, offset << 2);
		GL.enableVertexAttribArray(a);
	}

	public static inline function bindBuffer(v:VertexBuffer):Void
	{
		if (_activeState.buffer == v) return;

		GL.bindBuffer(GL.ARRAY_BUFFER, v.buffer);
		_activeState.buffer = v;
	}

	public static inline function createBuffer(stride:Int):VertexBuffer
	{
		return new VertexBuffer(GL.createBuffer(), stride << 2);
	}

	public static inline function updateBuffer(data:FloatArray, ?usage:BufferUsage):Void
	{
		GL.bufferData(GL.ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}

	public static inline function updateIndexBuffer(data:IntArray, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer
	{
		if (buffer == null) buffer = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
		_activeState.indexBuffer = buffer;
		return buffer;
	}

	public static inline function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		_renderCalls++;
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		GL.drawElements(GL.TRIANGLES, numTriangles * 3, GL.UNSIGNED_SHORT, offset << 2);
	}

	/**
	 * Compiles the shader source into a GlShader object and prints any errors
	 * @param source  The shader source code
	 * @param type    The type of shader to compile (fragment, vertex)
	 */
	private static inline function compileShader(program:ShaderProgram, source:String, type:Int):GLShader
	{
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);

		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
		{
			trace(GL.getShaderInfoLog(shader));
			shader = null;
		}

		if (shader != null)
		{
			GL.attachShader(program, shader);
			GL.deleteShader(shader);
		}

		return shader;
	}

	public static inline function setScissor(?clip:Rectangle)
	{
		if (clip == null)
		{
			GL.disable(GL.SCISSOR_TEST);
		}
		else
		{
			var scale = window.pixelScale; // retina window scale
			GL.enable(GL.SCISSOR_TEST);
			// flip from top left to bottom left
			GL.scissor(Std.int(clip.x * scale), Std.int((window.height - (clip.y + clip.height)) * scale),
				Std.int(clip.width * scale), Std.int(clip.height * scale));
		}
	}

	public static inline function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (_activeState.depthTest == test) return;

		if (depthMask)
		{
			GL.enable(GL.DEPTH_TEST);
			switch (test)
			{
				case NEVER: GL.depthFunc(GL.NEVER);
				case ALWAYS: GL.depthFunc(GL.ALWAYS);
				case GREATER: GL.depthFunc(GL.GREATER);
				case GREATER_EQUAL: GL.depthFunc(GL.GEQUAL);
				case LESS: GL.depthFunc(GL.LESS);
				case LESS_EQUAL: GL.depthFunc(GL.LEQUAL);
				case EQUAL: GL.depthFunc(GL.EQUAL);
				case NOT_EQUAL: GL.depthFunc(GL.NOTEQUAL);
			}
		}
		else
		{
			GL.disable(GL.DEPTH_TEST);
		}
		_activeState.depthTest = test;
	}


	private static var _renderCalls:Float = 0;
	private static var _totalRenderCalls:Float = 0;
	private static var _activeState:ActiveState = new ActiveState();

	private static var FORMAT = [
		GL.ALPHA,
		GL.LUMINANCE,
		GL.RGB,
		GL.RGBA
	];

	private static var BLEND = [
		GL.ZERO,
		GL.ONE,
		GL.SRC_ALPHA,
		GL.SRC_COLOR,
		GL.DST_ALPHA,
		GL.DST_COLOR,
		GL.ONE_MINUS_SRC_ALPHA,
		GL.ONE_MINUS_SRC_COLOR,
		GL.ONE_MINUS_DST_ALPHA,
		GL.ONE_MINUS_DST_COLOR
	];

	static var COMPARE = [
		GL.ALWAYS,
		GL.NEVER,
		GL.EQUAL,
		GL.NOTEQUAL,
		GL.GREATER,
		GL.GEQUAL,
		GL.LESS,
		GL.LEQUAL
	];

	static var CULL = [
		GL.NONE,
		GL.BACK,
		GL.FRONT,
		GL.FRONT_AND_BACK
	];

}

#end
