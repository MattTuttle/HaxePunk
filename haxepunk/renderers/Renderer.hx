package haxepunk.renderers;

import haxe.ds.IntMap;
import haxe.io.Bytes;
import haxepunk.graphics.*;
import haxepunk.math.*;

#if lime
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.graphics.Image;
#end

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

// ----------------------------------------------
// Type defines for rendering
// ----------------------------------------------
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

	typedef IndexBuffer = flash.display3D.IndexBuffer3D;

#elseif lime

	typedef FloatArray = lime.utils.Float32Array;
	typedef IntArray = lime.utils.Int16Array;

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

#else

	typedef FloatArray = Array<Float>;
	typedef IntArray = Array<UInt>;

#end

class Renderer
{

	public var window(default, null):Window;

	public function new(window:Window) { this.window = window; }

	public function clear(color:Color):Void { }
	public function setViewport(viewport:Rectangle):Void { }
	public function present():Void {
		_totalRenderCalls += _renderCalls;
		_renderCalls = 0;
	}
	public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void { }
	public function setCullMode(mode:CullMode):Void { }
	public function capture(viewport:Rectangle):Null<Image> { return null; }
	public function deleteTexture(texture:Texture):Void { }
	public function bindTexture(texture:Texture, sampler:Int):Void { }
	public function bindShader(?shader:Shader):Void { }
	public function setMatrix(uniform:String, matrix:Matrix4):Void { }
	public function setVector3(uniform:String, vec:Vector3):Void { }
	public function setColor(uniform:String, color:Color):Void { }
	public function setFloat(uniform:String, value:Float):Void { }
	public function setAttribute(attribute:String, offset:Int, num:Int):Void { }
	public function bindBuffer(v:VertexBuffer):Void { }
	public function createBuffer(stride:Int):Null<VertexBuffer> { return null; }
	public function updateBuffer(data:FloatArray, ?usage:BufferUsage):Void { }
	public function updateIndexBuffer(data:IntArray, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer { return null; }
	public function setScissor(?clip:Rectangle):Void { }
	public function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void {
		_renderCalls++;
	}
	public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void { }

	private var _renderCalls:Float = 0;
	private var _totalRenderCalls:Float = 0;

	private var _blendSource:BlendFactor;
	private var _blendDestination:BlendFactor;
	private var _shader:Shader;
	private var _buffer:VertexBuffer;
	private var _indexBuffer:IndexBuffer;
	private var _depthTest:DepthTestCompare;

}
