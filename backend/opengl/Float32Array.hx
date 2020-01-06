package backend.opengl;

import haxe.Int32;

#if hl

typedef FloatData = {
	length:Int,
	bytes:hl.Bytes
}

@:forward(length)
abstract Float32Array(FloatData)
{
	public static var BYTES_PER_ELEMENT:Int = 4;

	public function new(?length:Int, ?values:Array<Float>)
	{
		if (values != null)
		{
			length = values.length;
		}

		this = { length: length, bytes: new hl.Bytes(length * BYTES_PER_ELEMENT) };

		if (values != null)
		{
			for (i in 0...length)
			{
				this.bytes.setF32(i * BYTES_PER_ELEMENT, values[i]);
			}
		}
	}

	@:to public function toBytes():hl.Bytes
	{
		return this.bytes;
	}

	@:arrayAccess
	public inline function get(index:Int) {
		return this.bytes.getF32(index * 4);
	}

	@:arrayAccess
	public inline function arrayWrite(index:Int, value:Float):Float {
		this.bytes.setF32(index * 4, value);
		return value;
	}
}

#elseif lime

#if cpp
typedef Float32 = cpp.Float32;
#else
typedef Float32 = Float;
#end

@:forward
@:arrayAccess
abstract Float32Array(Array<Float32>) from Array<Float32> to Array<Float32>
{
	public static inline var BYTES_PER_ELEMENT = 4;

	public function new(inBufferOrArray:Dynamic, inStart:Int = 0, ?inElements:Null<Int>)
	{
		return new Array<Float32>();
	}

	public function setInt32(pos:Int, value:Int32)
	{
		// TODO: need a better way to set this value so it doesn't have precision loss
		this[pos] = value;
	}
}

#elseif js

typedef Float32Array = js.lib.Float32Array;

#else

#error "Float32Array is not defined"

#end
