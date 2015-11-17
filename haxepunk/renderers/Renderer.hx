package haxepunk.renderers;

import haxe.ds.IntMap;
import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.graphics.Image;

enum BufferUsage {
	STATIC_DRAW;
	DYNAMIC_DRAW;
}

@:enum abstract BlendFactor(Int) to (Int) {
	var ZERO = 0;
	var ONE = 1;
	var SOURCE_ALPHA = 2;
	var SOURCE_COLOR = 3;
	var DEST_ALPHA = 4;
	var DEST_COLOR = 5;
	var ONE_MINUS_SOURCE_ALPHA = 6;
	var ONE_MINUS_SOURCE_COLOR = 7;
	var ONE_MINUS_DEST_ALPHA = 8;
	var ONE_MINUS_DEST_COLOR = 9;
}

@:enum abstract ImageFormat(Int) to (Int) {
	var ALPHA = 0;
	var LUMINANCE = 1;
	var RGB = 2;
	var RGBA = 3;
}

@:enum abstract CullMode(Int) to (Int) {
	var NONE = 0;
	var BACK = 1;
	var FRONT = 2;
	var FRONT_AND_BACK = 3;
}

@:enum abstract DepthTestCompare(Int) to (Int) {
	var ALWAYS = 0;
	var NEVER = 1;
	var EQUAL = 2;
	var NOT_EQUAL = 3;
	var GREATER = 4;
	var GREATER_EQUAL = 5;
	var LESS = 6;
	var LESS_EQUAL = 7;
}

class ActiveState
{
	public var blendSource:BlendFactor;
	public var blendDestination:BlendFactor;
	public var program:ShaderProgram;
	public var texture:NativeTexture;
	public var buffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;
	public var depthTest:DepthTestCompare;

	public function new()
	{
	}
}

#if flash

typedef FloatArray = Array<Float>;
typedef IntArray = Array<UInt>;

class VertexBuffer
{
	public var stride:Int;
	public var buffer:flash.display3D.VertexBuffer3D;

	public function new(buffer:flash.display3D.VertexBuffer3D, stride:Int)
	{
		this.buffer = buffer;
		this.stride = stride;
	}
}

typedef ShaderProgram = flash.display3D.Program3D;
typedef IndexBuffer = flash.display3D.IndexBuffer3D;
typedef NativeTexture = flash.display3D.textures.Texture;
typedef Location = Int;

typedef Renderer = FlashRenderer;

#else

typedef FloatArray = lime.utils.Float32Array;
typedef IntArray = lime.utils.Int16Array;

typedef ShaderProgram = lime.graphics.opengl.GLProgram;
typedef Location = lime.graphics.opengl.GLUniformLocation;

class VertexBuffer
{
	public var stride:Int;
	public var buffer:lime.graphics.opengl.GLBuffer;

	public function new(buffer:lime.graphics.opengl.GLBuffer, stride:Int)
	{
		this.buffer = buffer;
		this.stride = stride;
	}
}

typedef IndexBuffer = lime.graphics.opengl.GLBuffer;
typedef NativeTexture = lime.graphics.opengl.GLTexture;
typedef Renderer = GLRenderer;

#end
