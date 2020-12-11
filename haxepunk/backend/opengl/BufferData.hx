package haxepunk.backend.opengl;

#if !doc

#if js
#if haxe4
import js.lib.Uint32Array;
#else
import js.html.Uint32Array;
#end
#end
import haxepunk.graphics.hardware.DrawCommand;

class BufferData
{
	static inline var INITIAL_SIZE:Int = 100;

	static inline function resize(numFloats:Int, minChunks:Int, chunkSize:Int)
	{
		return Std.int(Math.max(
			Std.int(numFloats * 2 / chunkSize),
			minChunks
		) * chunkSize);
	}

	#if hl
	var buffer:hl.Bytes;
	#else
	var buffer:Float32Array;
	#end

	#if js
	var intView:Uint32Array;
	#end

	#if cpp
	var bytesData:haxe.io.BytesData;
	#end

	public var numFloats(default, null):Int = 0;

	inline function bufferBytesSize():Int {
		#if hl
		return numFloats * 4;
		#else
		return numFloats * Float32Array.BYTES_PER_ELEMENT;
		#end
	}

	var byteOffset:Int;

	public function new() {}

	public function needsResize(triangles:Int, floatsPerTriangle:Int):Bool
	{
		if (numFloats < triangles * floatsPerTriangle)
		{
			numFloats = resize(numFloats, triangles, floatsPerTriangle);

#if hl
			buffer = new hl.Bytes(bufferBytesSize());
#else
			buffer = new Float32Array(numFloats);
	#if js
			// overlap int array with float array
			intView = new Uint32Array(buffer.buffer, 0);
	#end
#end
			return true;

			reset();
		}
		return false;
	}

	public function reset()
	{
#if cpp
		byteOffset = buffer.byteOffset;
		bytesData = buffer.buffer.getData();
#else
		byteOffset = 0;
#end
	}

	public inline function addFloat(v:Float)
	{
#if cpp
		var bytesData = bytesData;
		var offset = byteOffset; // helps hxcpp generator
		untyped __global__.__hxcpp_memory_set_float(bytesData, offset, v);
		byteOffset = offset + 4;
#elseif hl
		buffer.setF32(byteOffset, v);
		byteOffset += 4;
#else
		buffer[byteOffset] = v;
		byteOffset += 1;
#end
	}

	public inline function addVec(x:Float, y:Float)
	{
#if cpp
		var bytesData = bytesData;
		var offset = byteOffset; // helps hxcpp generator
		untyped __global__.__hxcpp_memory_set_float(bytesData, offset, x);
		untyped __global__.__hxcpp_memory_set_float(bytesData, offset+4, y);
		byteOffset = offset + 8;
#elseif hl
		buffer.setF32(byteOffset, x);
		buffer.setF32(byteOffset+4, y);
		byteOffset += 8;
#else
		buffer[byteOffset] = x;
		buffer[byteOffset + 1] = y;
		byteOffset += 2;
#end
	}

	public inline function addInt(value:UInt)
	{
#if cpp
		untyped __global__.__hxcpp_memory_set_ui32(bytesData, byteOffset, value);
		byteOffset += 4;
#elseif js
		intView[byteOffset] = value;
		byteOffset += 1;
#elseif hl
		buffer.setI32(byteOffset, value);
		byteOffset += 4;
#elseif java
		cast(buffer, java.nio.ByteBuffer).putInt(byteOffset, value);
		byteOffset += 4;
#else
		buffer.buffer.setInt32(byteOffset * 4, value);
		byteOffset += 1;
#end
	}

	// Add DrawCommand triangle position only
	public function prepareVertexOnly(drawCommand:DrawCommand)
	{
		for (tri in drawCommand.triangles)
		{
			addVec(tri.tx1, tri.ty1);
			addVec(tri.tx2, tri.ty2);
			addVec(tri.tx3, tri.ty3);
		}
	}

	public function prepareVertexAndColor(drawCommand:DrawCommand)
	{
		var triangleColor:UInt = 0;
		for (tri in drawCommand.triangles)
		{
			triangleColor = tri.color.withAlpha(tri.alpha);

			addVec(tri.tx1, tri.ty1);
			addInt(triangleColor);

			addVec(tri.tx2, tri.ty2);
			addInt(triangleColor);

			addVec(tri.tx3, tri.ty3);
			addInt(triangleColor);
		}
	}

	public function prepareVertexAndUV(drawCommand:DrawCommand)
	{
		for (tri in drawCommand.triangles)
		{
			addVec(tri.tx1, tri.ty1);
			addVec(tri.uvx1, tri.uvy1);

			addVec(tri.tx2, tri.ty2);
			addVec(tri.uvx2, tri.uvy2);

			addVec(tri.tx3, tri.ty3);
			addVec(tri.uvx3, tri.uvy3);
		}
	}

	public function prepareVertexUVandColor(drawCommand:DrawCommand)
	{
		var triangleColor:UInt = 0;
		for (tri in drawCommand.triangles)
		{
			triangleColor = tri.color.withAlpha(tri.alpha);

			addVec(tri.tx1, tri.ty1);
			addVec(tri.uvx1, tri.uvy1);
			addInt(triangleColor);

			addVec(tri.tx2, tri.ty2);
			addVec(tri.uvx2, tri.uvy2);
			addInt(triangleColor);

			addVec(tri.tx3, tri.ty3);
			addVec(tri.uvx3, tri.uvy3);
			addInt(triangleColor);
		}
	}
}

#end // !doc
