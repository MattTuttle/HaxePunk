package haxepunk.backend.opengl.shader;

#if !doc

import haxepunk.backend.opengl.render.GLRenderer;
import haxepunk.backend.opengl.GL;
import haxepunk.graphics.hardware.DrawCommand;
import haxepunk.backend.opengl.render.BufferData;
import haxepunk.HXP;
import haxepunk.utils.Log;

class Attribute
{
	public var index(default, null):Int = -1;
	public var data(default, set):Array<Float>;
	private function set_data(v:Array<Float>) : Array<Float>
	{
		dataPos = -1;
		return data = v;
	}
	public var valuesPerElement:Int;

	@:allow(haxepunk.backend.opengl.render.BufferData)
	private var dataPos(default, set):Int = -1; // for use by RenderBuffer to push data in VBOs
	private function set_dataPos(v:Int) : Int
	{
		return dataPos = v > -1 && data != null ? v % data.length : v;
	}

	public var name(default, set):String;
	public inline function set_name(value:String):String
	{
		name = value;
		rebind(); // requires name to be set
		if (index == -1)
			Log.warning("attribute '" + name + "' is not declared or not used in shader source.");
		return name;
	}

	public var isEnabled(get, null):Bool;
	private function get_isEnabled() : Bool return name != null && index != -1;

	var parent:Shader;

	public function new(parent:Shader)
	{
		this.parent = parent;
	}

	public function rebind()
	{
		if (name != null) index = parent.attributeIndex(name);
		dataPos = -1;
	}
}

class Shader implements haxepunk.backend.generic.render.Shader
{
	public var glProgram:GLProgram;
	public var floatsPerVertex(get, never):Int;
	function get_floatsPerVertex():Int
	{
		var a = 2 + (texCoord.isEnabled ? 2 : 0) + (color.isEnabled ? 1 : 0);
		for (v in attributes.iterator())
			if (v.isEnabled)
				a += v.valuesPerElement;
		return a;
	}

	public var vertexSource:String;
	var fragmentSource:String;

	public var id(default, null):Int;
	static var idSeq:Int = 0;

	public var position:Attribute;
	public var texCoord:Attribute;
	public var color:Attribute;

	public inline function hasAttributes():Bool
	{
		return attributeNames.length > 0;
	}
	var attributeNames:Array<String> = new Array();
	var attributes:Map<String, Attribute> = new Map();
	var uniformIndices:Map<String, GLUniformLocation> = new Map();
	var uniformNames:Array<String> = new Array();
	var uniformValues:Map<String, Float> = new Map();

	public function new(vertexSource:String, fragmentSource:String)
	{
		position = new Attribute(this);
		texCoord = new Attribute(this);
		color = new Attribute(this);
		this.vertexSource = vertexSource;
		this.fragmentSource = fragmentSource;
#if !unit_test
		build();
#end

		id = idSeq++;

		Log.info('Shader #$idSeq initialized');
	}

	public inline function equals(other:haxepunk.backend.generic.render.Shader):Bool
	{
		return this.id == cast(other, Shader).id;
	}

	public function build()
	{
		glProgram = GLRenderer.build(vertexSource, fragmentSource);
		position.rebind();
		texCoord.rebind();
		color.rebind();
		for (v in attributes.iterator())
			v.rebind();
	}

	public function destroy()
	{
		for (key in uniformIndices.keys()) uniformIndices.remove(key);
		for (key in attributes.keys()) attributes.remove(key);
	}

	static var _attribs:Array<Attribute> = new Array();
	public function prepare(drawCommand:DrawCommand, buffer:BufferData)
	{
		if (!position.isEnabled) return;
		HXP.clear(_attribs);
		for (name in attributeNames)
		{
			if (attributes[name].isEnabled) _attribs.push(attributes[name]);
		}

		buffer.reset();
		if (texCoord.isEnabled)
		{
			if (color.isEnabled)
			{
				buffer.prepareVertexUVandColor(drawCommand);
			}
			else
			{
				buffer.prepareVertexAndUV(drawCommand);
			}
		}
		else if (color.isEnabled)
		{
			buffer.prepareVertexAndColor(drawCommand);
		}
		else
		{
			buffer.prepareVertexOnly(drawCommand);
		}

		buffer.addVertexAttribData(_attribs, drawCommand.triangleCount * 3);

		GLRenderer.bufferSubData(buffer);

		setAttributePointers(drawCommand.triangleCount);
	}

	function setAttributePointers(nbTriangles:Int)
	{
		var vertexAttribPointer = #if (!lime && js) GLRenderer._GL.vertexAttribPointer #else GL.vertexAttribPointer #end;

		var bytesPerElement = Float32Array.BYTES_PER_ELEMENT;
		var offset:Int = 0;
		// var stride:Int = floatsPerVertex * bytesPerElement;
		var stride:Int = (2 + (texCoord.isEnabled ? 2 : 0) + (color.isEnabled ? 1 : 0)) * bytesPerElement;
		vertexAttribPointer(position.index, 2, GL.FLOAT, false, stride, offset);
		offset += 2 * bytesPerElement;

		if (texCoord.isEnabled)
		{
			vertexAttribPointer(texCoord.index, 2, GL.FLOAT, false, stride, offset);
			offset += 2 * bytesPerElement;
		}

		if (color.isEnabled)
		{
			vertexAttribPointer(color.index, 4, GL.UNSIGNED_BYTE, true, stride, offset);
			offset += 1 * bytesPerElement;
		}

		// Custom vertex attrib data is at the end of the buffer to speed up construction.

		offset *= nbTriangles * 3;

		// Use an array of names to preserve order, since the order of keys in a Map is undefined
		for (n in attributeNames)
		{
			var attrib = attributes[n];
			if (attrib.isEnabled)
			{
				vertexAttribPointer(attrib.index, attrib.valuesPerElement, GL.FLOAT, false, 0, offset);
				offset += nbTriangles * 3 * attrib.valuesPerElement * bytesPerElement;
			}
		}
	}

	public function bind()
	{
		#if (!lime && js) var GL = GLRenderer._GL; #end
		if (GLUtils.invalid(glProgram))
		{
			destroy();
			build();
		}

		GL.useProgram(glProgram);

		for (name in uniformNames)
		{
			#if hl
			var length = Float32Array.BYTES_PER_ELEMENT;
			GL.uniform4fv(uniformIndex(name), hl.Bytes.fromValue(uniformValues[name], length), 0, 4);
			#else
			GL.uniform1f(uniformIndex(name), uniformValues[name]);
			#end
		}

		GL.enableVertexAttribArray(position.index);
		if (texCoord.isEnabled) GL.enableVertexAttribArray(texCoord.index);
		if (color.isEnabled) GL.enableVertexAttribArray(color.index);
		for (n in attributeNames)
			if (attributes[n].isEnabled)
				GL.enableVertexAttribArray(attributes[n].index);

		GLRenderer.checkForErrors();
	}

	public function unbind()
	{
		#if (!lime && js) var GL = GLRenderer._GL; #end
		GL.useProgram(null);
		GL.disableVertexAttribArray(position.index);
		if (texCoord.isEnabled) GL.disableVertexAttribArray(texCoord.index);
		if (color.isEnabled) GL.disableVertexAttribArray(color.index);
		for (n in attributeNames)
			if (attributes[n].isEnabled)
				GL.disableVertexAttribArray(attributes[n].index);
	}

	/**
	 * Returns the index of a named shader attribute.
	 */
	public inline function attributeIndex(name:String):Int
	{
		#if (!lime && js) var GL = GLRenderer._GL; #end
#if unit_test
		return 0;
#else
		return GL.getAttribLocation(glProgram, name);
#end
	}

	/**
	 * Returns the index of a named shader uniform.
	 */
	public inline function uniformIndex(name:String):GLUniformLocation
	{
		#if (!lime && js) var GL = GLRenderer._GL; #end
		if (!uniformIndices.exists(name))
		{
			uniformIndices[name] = GL.getUniformLocation(glProgram, name);
		}
		return uniformIndices[name];
	}

	/**
	 * Set or change the value of a named shader uniform.
	 */
	public inline function setUniform(name:String, value:Float)
	{
		if (!uniformValues.exists(name))
		{
			uniformNames.push(name);
		}
		uniformValues[name] = value;
	}

	/**
	 * Set or change the values of a named vertex attribute.
	 */
	public function setVertexAttribData(name:String, values:Array<Float>, valuesPerElement:Int)
	{
		var attrib:Attribute;
		if (!attributes.exists(name))
		{
			attrib = new Attribute(this);
			attrib.name = name;
			attributes[name] = attrib;
			attributeNames.push(name);
		}
		else
			attrib = attributes[name];
		attrib.data = values;
		attrib.valuesPerElement = valuesPerElement;
	}

	/**
	 * Add extra values to a named vertex attribute.
	 */
	public function appendVertexAttribData(name:String, values:Array<Float>)
	{
		var attrib:Attribute;
		if (!attributes.exists(name))
			throw "appendVertexAttribData : attribute '" + name + "' was not declared";
		else
			attrib = attributes[name];
		if (values.length % attrib.valuesPerElement != 0)
			throw "appendVertexAttribData : values per element do not match";
		attrib.data = attrib.data.concat(values);
	}
}

#end // !doc
