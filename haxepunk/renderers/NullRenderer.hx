package haxepunk.renderers;

import haxepunk.graphics.Color;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;

class NullRenderer
{

	public static inline function clear(color:Color):Void { }
	public static inline function setViewport(x:Int, y:Int, width:Int, height:Int):Void { }
	public static inline function attribute(program:ShaderProgram, a:String):Int { return 0; }
	public static inline function uniform(program:ShaderProgram, u:String):Location { return null; }
	public static inline function present():Void { }
	public static inline function setBlendMode(source:BlendFactor, destination:BlendFactor):Void { }
	public static inline function setCullMode(mode:CullMode):Void { }
	public static inline function capture(x:Int, y:Int, width:Int, height:Int):Image { return null; }
	public static inline function createTexture(image:ImageBuffer):NativeTexture { return null; }
	public static inline function createTextureFromBytes(bytes:Bytes, width:Int, height:Int, bitsPerPixel:Int):NativeTexture { return null; }
	public static inline function deleteTexture(texture:NativeTexture):Void { }
	public static inline function bindTexture(texture:NativeTexture, sampler:Int):Void { }
	public static inline function compileShaderProgram(vertex:String, fragment:String):ShaderProgram { return null; }
	public static inline function bindProgram(?program:ShaderProgram):Void { }
	public static inline function setMatrix(loc:Location, matrix:Matrix4):Void { }
	public static inline function setVector3(loc:Location, vec:Vector3):Void { }
	public static inline function setColor(loc:Location, color:Color):Void { }
	public static inline function setFloat(loc:Location, value:Float):Void { }
	public static inline function setAttribute(a:Int, offset:Int, num:Int):Void { }
	public static inline function bindBuffer(v:VertexBuffer):Void { }
	public static inline function createBuffer(stride:Int):VertexBuffer { }
	public static inline function updateBuffer(data:FloatArray, ?usage:BufferUsage):Void { }
	public static inline function updateIndexBuffer(data:IntArray, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer { return null; }
	public static inline function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void { }
	public static inline function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void { }

}
