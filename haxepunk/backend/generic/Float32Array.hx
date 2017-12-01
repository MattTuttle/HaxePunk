package haxepunk.backend.generic;

import haxe.io.Bytes;
import haxe.io.BytesData;

abstract Float32Array(Bytes) from Bytes to Bytes
{
	public static inline var BYTES_PER_ELEMENT = 4;

	public var buffer(get, never):Float32Array;
	inline function get_buffer():Float32Array return this;

	public function new(size:Int)
	{
		return Bytes.alloc(size * BYTES_PER_ELEMENT);
	}

	public var length(get, never):Int;
	inline function get_length():Int return Std.int(this.length / 4);

	@:to
	public function toBytesData():BytesData
	{
		return this.getData();
	}

	@:arrayAccess
	public inline function get(pos:Int)
	{
		return this.getFloat(pos * 4);
	}

	@:arrayAccess
	public inline function arrayWrite(pos:Int, v:Float):Float
	{
		this.setFloat(pos * 4, v);
		return v;
	}

	public function setInt32(pos:Int, value:Int)
	{
		this.setInt32(pos, value);
	}
}
