package backend.opengl.render;

#if js
#if haxe4
import js.lib.Int32Array;
#else
import js.html.Int32Array;
#end
#end
import backend.opengl.shader.Shader.Attribute;
import haxepunk.graphics.hardware.DrawCommand;

class RenderBuffer
{
	static inline var INITIAL_SIZE:Int = 100;

	static inline function resize(length:Int, minChunks:Int, chunkSize:Int)
	{
		return Std.int(Math.max(
			Std.int(length * 2 / chunkSize),
			minChunks
		) * chunkSize);
	}

	var buffer:Float32Array;
	public var glBuffer:GLBuffer;

	public var length(default, null):Int = 0;

	#if js
	var intArray:Int32Array;
	#end

	#if cpp
	var bytesData:haxe.io.BytesData;
	#end

	var byteOffset:Int;

	public function new()
	{
		init();
	}

	public function init()
	{
		glBuffer = GL.createBuffer();
	}

	inline function bufferData(target, size, srcData, usage:Int)
	{
		#if hl
		GL.bufferData(target, size, hl.Bytes.getArray(srcData), usage);
		#elseif (html5 && lime >= "5.0.0")
		GL.bufferDataWEBGL(target, srcData, usage);
		#elseif (lime >= "4.0.0")
		GL.bufferData(target, size, srcData, usage);
		#else
		GL.bufferData(target, srcData, usage);
		#end
	}

	public function ensureSize(triangles:Int, floatsPerTriangle:Int)
	{
		if (GLUtils.invalid(glBuffer))
		{
			buffer = null;
			init();
		}

		if (length < triangles * floatsPerTriangle)
		{
			length = resize(length, triangles, floatsPerTriangle);

			buffer = new Float32Array(length);
			#if js
			intArray = new Int32Array(buffer.buffer);
			#end

			use();

			bufferData(GL.ARRAY_BUFFER, length * Float32Array.BYTES_PER_ELEMENT, buffer, GL.DYNAMIC_DRAW);
		}
	}

	public function use()
	{
		GL.bindBuffer(GL.ARRAY_BUFFER, glBuffer);
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
#else
		buffer[byteOffset] = x;
		buffer[byteOffset + 1] = y;
		byteOffset += 2;
#end
	}

	public inline function addInt(value:Int)
	{
#if cpp
		untyped __global__.__hxcpp_memory_set_ui32(bytesData, byteOffset, value);
		byteOffset += 4;
#elseif js
		intArray[byteOffset] = value;
		byteOffset += 1;
#else
		buffer.setInt32(byteOffset * 4, value);
		byteOffset += 1;
#end
	}

	/**
	 * Add vertex attribute data, at the end of the DrawCommand. While position, texture coords
	 * and color are interleaved, custom vertex attrib data is at the end of the buffer to speed
	 * up construction.
	 */
	public inline function addVertexAttribData(attribs:Array<Attribute>, nbVertices:Int)
	{
		for (attrib in attribs)
		{
			var attribData = attrib.data;
			for (k in 0 ... nbVertices * attrib.valuesPerElement)
				addFloat(attribData[++attrib.dataPos]);
		}
	}

	public inline function updateGraphicsCard()
	{
		#if hl
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, hl.Bytes.getArray(buffer), 0, length * Float32Array.BYTES_PER_ELEMENT);
		#elseif (html5 && lime >= "5.0.0")
		GL.bufferSubDataWEBGL(GL.ARRAY_BUFFER, 0, buffer);
		#elseif (lime >= "4.0.0")
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, length * Float32Array.BYTES_PER_ELEMENT, buffer);
		#else
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer);
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
