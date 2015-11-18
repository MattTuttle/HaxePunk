package haxepunk.graphics;

import haxe.ds.*;
import haxepunk.renderers.Renderer;
import haxepunk.math.Matrix4;

/**
 * Shader object for GLSL and AGAL
 */
class Shader
{

	public var vertex(default, null):String;
	public var fragment(default, null):String;

	/**
	 * Creates a new Shader
	 * @param sources  A list of glsl shader sources to compile and link into a program
	 */
	public function new(vertex:String, fragment:String)
	{
		this.vertex = vertex;
		this.fragment = fragment;
	}

	/**
	 * Bind the program for rendering
	 */
	public inline function use(renderer:Renderer):Void
	{
		renderer.bindShader(this);
	}

}
