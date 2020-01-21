package haxepunk.backend.opengl;

#if !doc

import haxepunk.backend.opengl.GL;
import haxepunk.graphics.shader.SceneShader;

class CompiledSceneShader extends CompiledShader
{
	public var width:Null<Int> = null;
	public var height:Null<Int> = null;

	public var textureWidth(get, never):Int;
	inline function get_textureWidth() return width == null ? HXP.screen.width : Std.int(Math.min(HXP.screen.width, width));

	public var textureHeight(get, never):Int;
	inline function get_textureHeight() return height == null ? HXP.screen.height : Std.int(Math.min(HXP.screen.height, height));

	public var smooth(get, never):Bool;
	inline function get_smooth() return cast(shader, SceneShader).smooth;

	public var active(get, never):Bool;
	inline function get_active() return cast(shader, SceneShader).active;

	public function setScale(sx:Float, sy:Float)
	{
		var w = this.textureWidth;
		var h = this.textureHeight;
		if (GLUtils.invalid(buffer) || GLUtils.invalid(v))
		{
			createBuffer();
		}
		else
		{
			GLRenderer.bindArrayBuffer(buffer);
		}

		var x:Float = w / HXP.screen.width,
			y:Float = h / HXP.screen.height;
		sx *= x;
		sy *= y;
		if (_lastX != x || _lastY != y || _lastSx != sx || _lastSy != sy)
		{
			#if nme
			inline function f(i) v[i] = sx * 2 - 1;
			f(4); f(12); f(16);
			inline function f(i) v[i] = -sy * 2 + 1;
			f(1); f(5); f(13);
			inline function f(i) v[i] = x;
			f(6); f(14); f(18);
			inline function f(i) v[i] = 1 - y;
			f(3); f(7); f(15);
			#else
			v[4] = v[12] = v[16] = sx * 2 - 1;
			v[1] = v[5] = v[13] = -sy * 2 + 1;
			v[6] = v[14] = v[18] = x;
			v[3] = v[7] = v[15] = 1 - y;
			#end

			GLRenderer.bufferData(GL.ARRAY_BUFFER, v.length * Float32Array.BYTES_PER_ELEMENT, v, GL.STATIC_DRAW);

			_lastX = x;
			_lastY = y;
			_lastSx = sx;
			_lastSy = sy;
		}
	}

	function createBuffer()
	{
		buffer = GLRenderer.createArrayBuffer();
		GLRenderer.bindArrayBuffer(buffer);
		v = new Float32Array(_vertices);
		var size = v.length * Float32Array.BYTES_PER_ELEMENT;
		GLRenderer.bufferData(GL.ARRAY_BUFFER, size, v, GL.STATIC_DRAW);
	}

	override public function build()
	{
		super.build();
		image = uniformIndex("uImage0");
		resolution = uniformIndex("uResolution");
	}

	override public function bind()
	{
		#if (!lime && js) var _GL = GLRenderer._GL; #end
		super.bind();
		if (GLUtils.invalid(buffer))
		{
			createBuffer();
		}

		_GL.vertexAttribPointer(position.index, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 0);
		_GL.vertexAttribPointer(texCoord.index, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);

		_GL.uniform1i(image, 0);
		#if hl
		var b = new hl.Bytes(4);
		b.setF32(0, HXP.screen.width);
		b.setF32(4, HXP.screen.height);
		b.setF32(8, 0);
		b.setF32(12, 0);
		_GL.uniform4fv(resolution, b, 0, 1);
		#else
		_GL.uniform2f(resolution, HXP.screen.width, HXP.screen.height);
		#end
	}

	var v:Float32Array;
	static var _vertices:Array<Float> = [
		-1.0, -1.0, 0, 0,
		1.0, -1.0, 1, 0,
		-1.0, 1.0, 0, 1,
		1.0, -1.0, 1, 0,
		1.0, 1.0, 1, 1,
		-1.0, 1.0, 0, 1
	];

	var image:GLUniformLocation;
	var resolution:GLUniformLocation;
	static var buffer:GLBuffer;

	static var _lastX:Float = 0;
	static var _lastY:Float = 0;
	static var _lastSx:Float = 0;
	static var _lastSy:Float = 0;
}

#end // !doc
