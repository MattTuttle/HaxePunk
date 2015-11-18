package haxepunk.renderers;

import haxe.io.Bytes;
import haxepunk.graphics.Color;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
#if flash
import com.adobe.utils.AGALMiniAssembler;
import flash.Lib;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.*;
import flash.display3D.textures.Texture;
import flash.events.Event;
#end
import lime.graphics.FlashRenderContext;
import lime.utils.Int16Array;
import lime.utils.Float32Array;
import lime.utils.UInt8Array;

class FlashRenderer extends Renderer
{

	override public function new(window:Window, context:FlashRenderContext, ready:Void->Void)
	{
		super(window);
#if flash
		_stage3D = context.stage.stage3Ds[0];
		_stage3D.addEventListener(Event.CONTEXT3D_CREATE, function (_) {
			_context = _stage3D.context3D;
			setViewport(new Rectangle(0, 0, context.stage.stageWidth, context.stage.stageHeight));
			_context.enableErrorChecking = true;
			ready();
		});
		_stage3D.requestContext3D();
#end
	}

#if flash

	override public function clear(color:Color):Void
	{
		_context.clear(color.r, color.g, color.b, color.a);
	}

	override public function attribute(program:ShaderProgram, a:String):Int
	{
		return _attributeId++; // TODO: come up with better solution...
	}

	override public function uniform(program:ShaderProgram, u:String):Location
	{
		return _uniformId++; // TODO: come up with better solution...
	}

	override public function setCullMode(mode:CullMode):Void
	{
		_context.setCulling(CULL[mode]);
	}

	override public function setViewport(viewport:Rectangle):Void
	{
		_stage3D.x = viewport.x;
		_stage3D.y = viewport.y;
		_context.configureBackBuffer(Std.int(viewport.width), Std.int(viewport.height), 4, true);
	}

	override public function present()
	{
		_context.present();
		// must reset program and texture at end of each frame...
		bindProgram();
		bindTexture(null, 0);
	}

	override public function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var assembler = new AGALMiniAssembler();
		var vertexShader = assembler.assemble(Context3DProgramType.VERTEX, vertex);
		var fragmentShader = assembler.assemble(Context3DProgramType.FRAGMENT, fragment);

		var program = _context.createProgram();
		program.upload(vertexShader, fragmentShader);

		return program;
	}

	override public function bindProgram(?program:ShaderProgram):Void
	{
		_context.setProgram(program);
	}

	override public function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		matrix.transpose(); // Flash requires a transposed matrix
		_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, loc, matrix.native, false);
	}

	override public function setVector3(loc:Location, vec:Vector3):Void
	{
		var uvec = new flash.Vector();
		uvec.push(vec.x);
		uvec.push(vec.y);
		uvec.push(vec.z);
		_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, loc, uvec);
	}

	override public function setColor(loc:Location, color:Color):Void
	{
		var vec = new flash.Vector();
		vec.push(color.r);
		vec.push(color.g);
		vec.push(color.b);
		vec.push(color.a);
		_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, loc, vec);
	}

	override public function setFloat(loc:Location, value:Float):Void
	{
		var vec = new flash.Vector();
		vec.push(value);
		_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, loc, vec);
	}

	override public function setAttribute(a:Int, offset:Int, num:Int):Void
	{
		_context.setVertexBufferAt(a, _activeState.buffer.buffer, offset, FORMAT[num]);
	}

	override public function bindBuffer(buffer:VertexBuffer):Void
	{
		_activeState.buffer = buffer;
	}

	override public function createBuffer(stride:Int):VertexBuffer
	{
		return new VertexBuffer(null, stride);
	}

	override public function updateBuffer(data:FloatArray, ?usage:BufferUsage):Void
	{
		var vb:VertexBuffer = _activeState.buffer;
		var len:Int = Std.int(data.length / vb.stride);
		if (vb.buffer != null) vb.buffer.dispose();
		vb.buffer = _context.createVertexBuffer(len, vb.stride);
		vb.buffer.uploadFromVector(flash.Vector.ofArray(data), 0, len);
	}

	override public function updateIndexBuffer(data:IntArray, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer
	{
		if (buffer != null) buffer.dispose();
		buffer = _context.createIndexBuffer(data.length);
		buffer.uploadFromVector(flash.Vector.ofArray(data), 0, data.length);
		return buffer;
	}

	override public function createTextureFromBytes(bytes:Bytes, width:Int, height:Int, bitsPerPixel:Int):NativeTexture
	{
		if (bitsPerPixel != 32) Log.error("Flash only supports 32 bit BGRA textures");
		var texture = _context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
		texture.uploadFromByteArray(bytes.getData(), 0);
		return texture;
	}

	override public function deleteTexture(texture:NativeTexture):Void
	{
		texture.dispose();
	}

	override public function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		_context.setTextureAt(sampler, texture);
	}

	override public function setScissor(?clip:Rectangle)
	{
		Log.warn("Not implemented");
	}

	override public function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		_context.drawTriangles(buffer, offset, numTriangles);
	}

	override public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		_context.setBlendFactors(BLEND[source], BLEND[destination]);
	}

	override public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (depthMask)
		{
			_context.setDepthTest(true, COMPARE[test]);
		}
		else
		{
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
		}
	}

	private var _attributeId:Int = 0;
	private var _uniformId:Int = 0;
	private var _context:Context3D;
	private var _activeState:ActiveState = new ActiveState();
	private var _stage3D:Stage3D;

	private static var BLEND = [
		Context3DBlendFactor.ZERO,
		Context3DBlendFactor.ONE,
		Context3DBlendFactor.SOURCE_ALPHA,
		Context3DBlendFactor.SOURCE_COLOR,
		Context3DBlendFactor.DESTINATION_ALPHA,
		Context3DBlendFactor.DESTINATION_COLOR,
		Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA,
		Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR,
		Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,
		Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR
	];

	static var COMPARE = [
		Context3DCompareMode.ALWAYS,
		Context3DCompareMode.NEVER,
		Context3DCompareMode.EQUAL,
		Context3DCompareMode.NOT_EQUAL,
		Context3DCompareMode.GREATER,
		Context3DCompareMode.GREATER_EQUAL,
		Context3DCompareMode.LESS,
		Context3DCompareMode.LESS_EQUAL,
	];

	private static var FORMAT = [
		Context3DVertexBufferFormat.BYTES_4,
		Context3DVertexBufferFormat.FLOAT_1,
		Context3DVertexBufferFormat.FLOAT_2,
		Context3DVertexBufferFormat.FLOAT_3,
		Context3DVertexBufferFormat.FLOAT_4,
	];

	private static var CULL = [
		Context3DTriangleFace.NONE,
		Context3DTriangleFace.BACK,
		Context3DTriangleFace.FRONT,
		Context3DTriangleFace.FRONT_AND_BACK,
	];

#end

}
