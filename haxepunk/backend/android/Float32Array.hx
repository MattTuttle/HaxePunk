package haxepunk.backend.android;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.nio.ByteOrder;

@:arrayAccess
abstract Float32Array(ByteBuffer)
{
	@:const public static inline var BYTES_PER_ELEMENT = 4;

	inline function allocate(size:Int) {
		return ByteBuffer.allocateDirect(size * BYTES_PER_ELEMENT);
	}

	@:to public inline function toFloatBuffer():FloatBuffer return this.asFloatBuffer();

	public function new(x:Dynamic) {
		if (Std.is(x, Array)) {
			this = allocate(x.length);
			var items:java.NativeArray<Single> = x;
            this.asFloatBuffer().put(items);
		} else {
			this = allocate(x);
		}
        this.order(ByteOrder.nativeOrder());
	}

	@:arrayAccess public inline function get(index:Int):Single {
		return this.getFloat(index);
	}

	@:arrayAccess public inline function set(index:Int, value:Single):Single {
		this.putFloat(index, value);
		return value;
	}

	public var length(get, never):Int;
	inline function get_length():Int return this.capacity() >> 2;
}
