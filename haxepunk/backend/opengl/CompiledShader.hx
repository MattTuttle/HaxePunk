package haxepunk.backend.opengl;

#if !doc

import haxepunk.backend.opengl.GL;
import haxepunk.graphics.hardware.DrawCommand;
import haxepunk.graphics.shader.Shader;

@:build(haxepunk.backend.opengl.GLUtils.replaceGL())
class CompiledAttribute
{
	public final index:Int;
	public final valuesPerElement:Int;
	public final dataType:Int;

	public function new(attribute:Attribute, glProgram:GLProgram)
	{
		index = gl.getAttribLocation(glProgram, attribute.name);
		switch (attribute.type)
		{
			case Position:
				valuesPerElement = 2;
				dataType = GL.FLOAT;
			case TexCoord:
				valuesPerElement = 2;
				dataType = GL.FLOAT;
			case VertexColor:
				valuesPerElement = 4;
				dataType = GL.UNSIGNED_BYTE;
			case Custom(v):
				valuesPerElement = v;
				dataType = GL.FLOAT;
		}
	}

	public var data(default, set):Array<Float>;
	function set_data(v:Array<Float>) : Array<Float>
	{
		dataPos = -1;
		return data = v;
	}

	public var dataPos(default, set):Int = -1; // for use by RenderBuffer to push data in VBOs
	function set_dataPos(v:Int) : Int
	{
		return dataPos = v > -1 && data != null ? v % data.length : v;
	}
}

@:access(haxepunk.graphics.shader.Shader)
@:build(haxepunk.backend.opengl.GLUtils.replaceGL())
class CompiledShader
{
	public var glProgram:GLProgram;

	public var floatsPerVertex(get, never):Int;
	function get_floatsPerVertex():Int
	{
		var a = 0;
		for (v in attributes)
		{
			a += v.valuesPerElement;
		}
		return a;
	}

	var shader:Shader;

	var uniformIndices:Map<String, GLUniformLocation> = new Map();

	var position:CompiledAttribute;
	var texCoord:CompiledAttribute;
	var color:CompiledAttribute;
	var customAttributes = new Array<CompiledAttribute>();
	var attributes = new Array<CompiledAttribute>();

	public function new(shader:Shader)
	{
		this.shader = shader;
		build();
	}

	public function build()
	{
		glProgram = GLRenderer.build(shader.vertexSource, shader.fragmentSource);
		rebindAttributes();
	}

	function rebindAttributes()
	{
		for (attribute in shader.attributes)
		{
			var compiled = new CompiledAttribute(attribute, glProgram);
			switch (attribute.type)
			{
				case Position: position = compiled;
				case TexCoord: texCoord = compiled;
				case VertexColor: color = compiled;
				case Custom(_): customAttributes.push(compiled);
			}
			attributes.push(compiled);
		}
		shader.dirty = false;
	}

	public function destroy()
	{
		for (key in uniformIndices.keys()) uniformIndices.remove(key);
		position = null;
		texCoord = null;
		color = null;
		customAttributes = [];
		attributes = [];
	}

	/**
	 * Add vertex attribute data, at the end of the DrawCommand. While position, texture coords
	 * and color are interleaved, custom vertex attrib data is at the end of the buffer to speed
	 * up construction.
	 */
	public inline function addVertexAttribData(buffer:BufferData, nbVertices:Int)
	{
		for (attrib in customAttributes)
		{
			var attribData = attrib.data;
			for (k in 0 ... nbVertices * attrib.valuesPerElement)
				buffer.addFloat(attribData[++attrib.dataPos]);
		}
	}

	public function prepare(drawCommand:DrawCommand, buffer:BufferData)
	{
		if (position == null)
		{
			Log.critical("Shader does not contain a position attribute");
			return;
		}

		buffer.reset();
		if (texCoord != null)
		{
			if (color != null)
			{
				buffer.prepareVertexUVandColor(drawCommand);
			}
			else
			{
				buffer.prepareVertexAndUV(drawCommand);
			}
		}
		else if (color != null)
		{
			buffer.prepareVertexAndColor(drawCommand);
		}
		else
		{
			buffer.prepareVertexOnly(drawCommand);
		}

		addVertexAttribData(buffer, drawCommand.triangleCount * 3);

		GLRenderer.bufferSubData(buffer);

		setAttributePointers(drawCommand.triangleCount);
	}

	function setAttributePointers(nbTriangles:Int)
	{
		var offset:Int = 0;

		var useTexCoord = texCoord != null;
		var useColor = color != null;

		var stride:Int = (2 + (useTexCoord ? 2 : 0) + (useColor ? 1 : 0)) * Float32Array.BYTES_PER_ELEMENT;
		gl.vertexAttribPointer(position.index, 2, GL.FLOAT, false, stride, offset);
		offset += 2 * Float32Array.BYTES_PER_ELEMENT;

		if (useTexCoord)
		{
			gl.vertexAttribPointer(texCoord.index, 2, GL.FLOAT, false, stride, offset);
			offset += 2 * Float32Array.BYTES_PER_ELEMENT;
		}

		if (useColor)
		{
			gl.vertexAttribPointer(color.index, 4, GL.UNSIGNED_BYTE, true, stride, offset);
			offset += 1 * Float32Array.BYTES_PER_ELEMENT;
		}

		// Custom vertex attrib data is at the end of the buffer to speed up construction.

		offset *= nbTriangles * 3;

		// Use an array of names to preserve order, since the order of keys in a Map is undefined
		for (attrib in customAttributes)
		{
			gl.vertexAttribPointer(attrib.index, attrib.valuesPerElement, GL.FLOAT, false, 0, offset);
			offset += nbTriangles * 3 * attrib.valuesPerElement * Float32Array.BYTES_PER_ELEMENT;
		}
	}

	#if hl
	var streamBytes:hl.Bytes;
	#end

	public function bind()
	{
		if (GLUtils.invalid(glProgram))
		{
			destroy();
			build();
		}
		if (shader.dirty) rebindAttributes();

		gl.useProgram(glProgram);

		#if hl
		var offset = 0;
		streamBytes = new hl.Bytes(shader.uniformNames.length * 16);
		#end

		for (name in shader.uniformNames)
		{
			#if hl
			streamBytes.setF32(offset, cast shader.uniformValues[name]);
			streamBytes.setF32(offset+4, 0);
			streamBytes.setF32(offset+8, 0);
			streamBytes.setF32(offset+12, 0);
			gl.uniform4fv(uniformIndex(name), streamBytes, offset, 1);
			offset += 16;
			#else
			gl.uniform1f(uniformIndex(name), shader.uniformValues[name]);
			#end
		}

		for (attribute in attributes)
		{
			gl.enableVertexAttribArray(attribute.index);
		}

		GLRenderer.checkForErrors();
	}

	public function unbind()
	{
		gl.useProgram(null);
		for (attribute in attributes)
		{
			gl.disableVertexAttribArray(attribute.index);
		}
	}

	/**
	 * Returns the index of a named shader uniform.
	 */
	public inline function uniformIndex(name:String):GLUniformLocation
	{
		if (!uniformIndices.exists(name))
		{
			uniformIndices[name] = gl.getUniformLocation(glProgram, name);
		}
		return uniformIndices[name];
	}
}

#end // !doc
