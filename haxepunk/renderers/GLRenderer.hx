package haxepunk.renderers;

#if !flash

import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import lime.graphics.*;
import lime.graphics.opengl.*;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.utils.UInt8Array;

class GLRenderer extends Renderer
{

	public var gl:GLRenderContext;

	public function new(window:Window, context:GLRenderContext)
	{
		super(window);
		gl = context;
	}

	override public function clear(color:Color):Void
	{
		gl.clearColor(color.r, color.g, color.b, color.a);
		gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	override public function setViewport(viewport:Rectangle):Void
	{
		gl.viewport(Std.int(viewport.x), Std.int(viewport.y), Std.int(viewport.width), Std.int(viewport.height));
	}

	override public function present():Void
	{
		super.present();
		#if js
		gl.finish();
		#end
	}

	override public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		if (_blendSource == source && _blendDestination == destination) return;

		if (source == ONE && destination == ZERO)
		{
			gl.disable(GL.BLEND);
		}
		else
		{
			gl.blendFunc(BLEND[source], BLEND[destination]);
			gl.enable(GL.BLEND);
		}

		_blendSource = source;
		_blendDestination = destination;
	}

	override public function setCullMode(mode:CullMode):Void
	{
		if (mode == NONE)
		{
			gl.disable(GL.CULL_FACE);
		}
		else
		{
			gl.enable(GL.CULL_FACE);
			gl.cullFace(CULL[mode]);
		}
	}

	override public function capture(rect:Rectangle):Null<Image>
	{
		var width = Std.int(rect.width),
			height = Std.int(rect.height);
		var bytesPerRow = width * 4;
		var pixels = new UInt8Array(height * bytesPerRow);
		gl.readPixels(Std.int(rect.x), Std.int(rect.y), width, height, GL.RGBA, GL.UNSIGNED_BYTE, pixels);
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

	override public function createTextureFromBytes(bytes:Bytes, width:Int, height:Int, bitsPerPixel:Int=32):NativeTexture
	{
		var format = switch (bitsPerPixel) {
			case 8: gl.ALPHA;
			case 24: gl.RGB;
			case 32: gl.RGBA;
			default: throw "Unsupported bits per pixel: " + bitsPerPixel;
		};
		var texture = gl.createTexture();
		gl.bindTexture(GL.TEXTURE_2D, texture);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		gl.texImage2D(GL.TEXTURE_2D, 0, format, width, height, 0, format, GL.UNSIGNED_BYTE, UInt8Array.fromBytes(bytes));
		return texture;
	}

	override public function deleteTexture(texture:Texture):Void
	{
		if (_textures.exists(texture.id))
		{
			gl.deleteTexture(_textures.get(texture.id));
			_textures.remove(texture.id);
		}
	}

	override public function bindTexture(texture:Texture, sampler:Int):Void
	{
		if (_lastTexture == texture.id) return;
		if (_textures.exists(texture.id))
		{
			_texture = _textures.get(texture.id);
		}
		else
		{
			_texture = createTextureFromBytes(texture.data, texture.width, texture.height, texture.bitsPerPixel);
			_textures.set(texture.id, _texture);
		}

		gl.activeTexture(GL.TEXTURE0 + sampler);
		gl.bindTexture(GL.TEXTURE_2D, _texture);
	}

	override public function bindShader(?shader:Shader):Void
	{
		// only switch if the shader changed
		if (_shader == shader) return;

		if (shader == null)
		{
			gl.useProgram(null);
		}
		else
		{
			if (!_programs.exists(shader))
			{
				_programs.set(shader, new Program(shader));
			}
			_program = _programs.get(shader);
			_program.bind(gl);
		}
		_shader = shader;
	}

	override public function setMatrix(uniform:String, matrix:Matrix4):Void
	{
		gl.uniformMatrix4fv(_program.uniform(uniform), false, matrix.native);
	}

	override public function setVector3(uniform:String, vec:Vector3):Void
	{
		gl.uniform3f(_program.uniform(uniform), vec.x, vec.y, vec.z);
	}

	override public function setColor(uniform:String, color:Color):Void
	{
		gl.uniform4f(_program.uniform(uniform), color.r, color.g, color.b, color.a);
	}

	override public function setFloat(uniform:String, value:Float):Void
	{
		gl.uniform1f(_program.uniform(uniform), value);
	}

	override public function setAttribute(attribute:String, offset:Int, num:Int):Void
	{
		var attrib = _program.attribute(attribute);
		gl.vertexAttribPointer(attrib, num, GL.FLOAT, false, _buffer.stride, offset << 2);
		gl.enableVertexAttribArray(attrib);
	}

	override public function bindBuffer(v:VertexBuffer):Void
	{
		if (_buffer == v) return;

		gl.bindBuffer(GL.ARRAY_BUFFER, v.buffer);
		_buffer = v;
	}

	override public function createBuffer(stride:Int):VertexBuffer
	{
		return new VertexBuffer(gl.createBuffer(), stride << 2);
	}

	override public function updateBuffer(data:FloatArray, ?usage:BufferUsage):Void
	{
		gl.bufferData(GL.ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}

	override public function updateIndexBuffer(data:IntArray, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer
	{
		if (buffer == null) buffer = gl.createBuffer();
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
		_indexBuffer = buffer;
		return buffer;
	}

	override public function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		super.draw(buffer, numTriangles, offset);
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		gl.drawElements(GL.TRIANGLES, numTriangles * 3, GL.UNSIGNED_SHORT, offset << 2);
	}

	override public function setScissor(?clip:Rectangle)
	{
		if (clip == null)
		{
			gl.disable(GL.SCISSOR_TEST);
		}
		else
		{
			var scale = window.pixelScale; // retina window scale
			gl.enable(GL.SCISSOR_TEST);
			// flip from top left to bottom left
			gl.scissor(Std.int(clip.x * scale), Std.int((window.height - (clip.y + clip.height)) * scale),
				Std.int(clip.width * scale), Std.int(clip.height * scale));
		}
	}

	override public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (_depthTest == test) return;

		if (depthMask)
		{
			gl.enable(GL.DEPTH_TEST);
			gl.depthFunc(switch (test) {
				case NEVER: GL.NEVER;
				case ALWAYS: GL.ALWAYS;
				case GREATER: GL.GREATER;
				case GREATER_EQUAL: GL.GEQUAL;
				case LESS: GL.LESS;
				case LESS_EQUAL: GL.LEQUAL;
				case EQUAL: GL.EQUAL;
				case NOT_EQUAL: GL.NOTEQUAL;
			});
		}
		else
		{
			gl.disable(GL.DEPTH_TEST);
		}
		_depthTest = test;
	}

	private var _textures = new StringMap<GLTexture>();
	private var _texture:GLTexture;
	private var _lastTexture:String;

	private var _programs = new Map<Shader, Program>();
	private var _program:Program;

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

// GL program
class Program
{
	public function new(shader:Shader)
	{
		_program = GL.createProgram();

		if (compileShader(_program, shader.vertex, GL.VERTEX_SHADER) != null)
		{
			if (compileShader(_program, shader.fragment, GL.FRAGMENT_SHADER) != null)
			{
				GL.linkProgram(_program);

				if (GL.getProgramParameter(_program, GL.LINK_STATUS) == 0)
				{
					Log.warn(GL.getProgramInfoLog(_program));
					Log.warn("VALIDATE_STATUS: " + GL.getProgramParameter(_program, GL.VALIDATE_STATUS));
					Log.error(Std.string(GL.getError()));
				}
			}
		}
	}

	/**
	 * Compiles the shader source into a GlShader object and prints any errors
	 * @param source  The shader source code
	 * @param type    The type of shader to compile (fragment, vertex)
	 */
	private function compileShader(program:GLProgram, source:String, type:Int):GLShader
	{
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);

		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
		{
			Log.info(GL.getShaderInfoLog(shader));
			shader = null;
		}

		if (shader != null)
		{
			GL.attachShader(program, shader);
			GL.deleteShader(shader);
		}

		return shader;
	}

	public inline function bind(gl:GLRenderContext):Void
	{
		gl.useProgram(_program);
	}

	public function attribute(a:String):Int
	{
		if (!_attributes.exists(a))
		{
			_attributes.set(a, GL.getAttribLocation(_program, a));
		}
		return _attributes.get(a);
	}

	public function uniform(u:String):GLUniformLocation
	{
		if (!_uniforms.exists(u))
		{
			_uniforms.set(u, GL.getUniformLocation(_program, u));
		}
		return _uniforms.get(u);
	}

	private var _program:GLProgram;
	private var _attributes = new StringMap<Int>();
	private var _uniforms = new StringMap<GLUniformLocation>();
}

#end
