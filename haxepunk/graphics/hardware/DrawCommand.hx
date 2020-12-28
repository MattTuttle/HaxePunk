package haxepunk.graphics.hardware;

import haxepunk.backend.opengl.BufferData;
import haxepunk.backend.opengl.Float32Array;
import haxepunk.graphics.shader.Shader;
import haxepunk.backend.generic.render.Texture;
import haxepunk.math.MathUtil;
import haxepunk.math.Rectangle;
import haxepunk.utils.BlendMode;
import haxepunk.utils.Color;

/**
 * Represents a pending hardware draw call. A single DrawCommand batches render
 * calls for the same texture, target and parameters. Based on work by
 * @Beeblerox.
 */
@:dox(hide)
class DrawCommand
{
	public static function create(texture:Texture, shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle)
	{
		var command:DrawCommand;
		if (_pool != null)
		{
			command = _pool;
			_pool = _pool._next;
			command._prev = command._next = null;
		}
		else
		{
			command = new DrawCommand();
		}
		command.shader = shader;
		command.texture = texture;
		command.smooth = smooth;
		command.blend = blend;
		command.clipRect = clipRect;
		return command;
	}

	static function _prePopulatePool(n:Int)
	{
		for (i in 0 ... n)
		{
			var cmd = new DrawCommand();
			// reset and put command in the pool
			cmd.recycle();
		}
		return _pool;
	}

	static var _pool:DrawCommand = _prePopulatePool(32);

	public var shader:Shader;
	public var texture:Texture;
	public var smooth:Bool = false;
	public var blend:BlendMode = BlendMode.Alpha;
	public var clipRect:Rectangle = null;

	var triangleCount:Int = 0;

	function new() {
		data = new BufferData();
	}

	public function empty():Bool return triangleCount == 0;

	public var indicies(get, never):Int;
	inline function get_indicies():Int return triangleCount * 3;

	/**
	 * Compares values to this draw command to see if they all match. This is used by the batcher to reuse the previous draw command.
	 */
	public inline function match(texture:Texture, shader:Shader, smooth:Bool, blend:BlendMode, clipRect:Rectangle):Bool
	{
		// These conditions are checked as individual if statements
		// to reduce the number of temporary variables created in hxcpp.
		if (this.smooth != smooth) return false;
		else if (this.texture != texture) return false;
		else if (this.shader.id != shader.id) return false;
		else if (this.blend != blend) return false;
		else
		{
			// It is faster to do a null check once and compare the results.
			var aRectIsNull = this.clipRect == null;
			var bRectIsNull = clipRect == null;
			if (aRectIsNull != bRectIsNull) return false; // one rect is null the other is not
			if (aRectIsNull) return true; // both are null, return true
			else return Std.int(this.clipRect.x) == Std.int(clipRect.x) &&
					Std.int(this.clipRect.y) == Std.int(clipRect.y) &&
					Std.int(this.clipRect.width) == Std.int(clipRect.width) &&
					Std.int(this.clipRect.height) == Std.int(clipRect.height);
		}
	}

	/**
	 * Add a triangle vertices to render.
	 * @param tx[1 && data != null-3]  Vrtex x coord
	 * @param ty[1-3]  Vertex y coord
	 * @param uvx[1-3] Texture x coord [0-1]
	 * @param uvy[1-3] Texture y coord [0-1]
	 * @param color    Vertex color tint
	 * @param alpha    Vertex alpha value
	 */
	public function addTriangle(tx1:Float, ty1:Float, uvx1:Float, uvy1:Float, tx2:Float, ty2:Float, uvx2:Float, uvy2:Float, tx3:Float, ty3:Float, uvx3:Float, uvy3:Float, color:Color):Void
	{
		data.needsResize(triangleCount, 15*4);
		data.addVec(tx1, ty1);
		data.addVec(uvx1, uvy1);
		data.addInt(color);
		data.addVec(tx2, ty2);
		data.addVec(uvx2, uvy2);
		data.addInt(color);
		data.addVec(tx3, ty3);
		data.addVec(uvx3, uvy3);
		data.addInt(color);
		++triangleCount;
	}

	public function addTriangleNoUV(tx1:Float, ty1:Float, tx2:Float, ty2:Float, tx3:Float, ty3:Float, color:Color):Void
	{
		data.needsResize(triangleCount, 9*4);
		data.addVec(tx1, ty1);
		data.addInt(color);
		data.addVec(tx2, ty2);
		data.addInt(color);
		data.addVec(tx3, ty3);
		data.addInt(color);
		++triangleCount;
	}

	public function recycle()
	{
		recycleData();
		var command = this;
		while (command._next != null)
		{
			command = command._next;
			command.recycleData();
		}
		command._next = _pool;
		_pool = this;
	}

	function recycleData()
	{
		triangleCount = 0;
		texture = null;
		data.reset();
	}

	@:allow(haxepunk) var data:BufferData;
	@:allow(haxepunk.graphics.hardware) var _prev:DrawCommand;
	@:allow(haxepunk.graphics.hardware) var _next:DrawCommand;
}
