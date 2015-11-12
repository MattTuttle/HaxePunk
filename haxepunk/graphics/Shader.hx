package haxepunk.graphics;

import haxe.ds.*;
import haxepunk.renderers.Renderer;
import haxepunk.math.Matrix4;

class Program
{

	public function new(program:ShaderProgram)
	{
		_program = program;
		_uniforms = new StringMap<Location>();
		_attributes = new StringMap<Int>();
	}

	/**
	 * Return the attribute location in this shader
	 * @param a  The attribute name to find
	 * @return the attribute location for binding
	 */
	public function attribute(a:String):Int
	{
		if (!_attributes.exists(a))
		{
			_attributes.set(a, Renderer.attribute(_program, a));
		}
		return _attributes.get(a);
	}

	/**
	 * Return the uniform location in this shader
	 * @param u  The uniform name to find
	 * @return the uniform location for binding
	 */
	public function uniform(u:String):Location
	{
		if (!_uniforms.exists(u))
		{
			_uniforms.set(u, Renderer.uniform(_program, u));
		}
		return _uniforms.get(u);
	}

	@:allow(haxepunk.graphics.Shader)
	private var _program:ShaderProgram;
	private var _attributes:StringMap<Int>;
	private var _uniforms:StringMap<Location>;

}

/**
 * Shader object for GLSL and AGAL
 */
class Shader
{

	public var program(get, never):Program;
	private function get_program():Program
	{
		var id = Renderer.window.id;
		if (_program.exists(id))
		{
			return _program.get(id);
		}
		{
			var program = new Program(Renderer.compileShaderProgram(_vertex, _fragment));
			_program.set(id, program);
			return program;
		}
	}

	/**
	 * Creates a new Shader
	 * @param sources  A list of glsl shader sources to compile and link into a program
	 */
	public function new(vertex:String, fragment:String)
	{
		_vertex = vertex;
		_fragment = fragment;
		_program = new IntMap<Program>();
	}

	/**
	 * Bind the program for rendering
	 */
	public inline function use():Void
	{
		Renderer.bindProgram(program._program);
	}

	private var _vertex:String;
	private var _fragment:String;
	private var _program:IntMap<Program>;

}
