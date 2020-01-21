package haxepunk.backend.opengl;

#if !doc

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

typedef Float32Array = lime.utils.Float32Array;

#elseif nme

import nme.utils.Float32Array as F32Array;

@:forward
@:arrayAccess
abstract Float32Array(F32Array) from F32Array to F32Array
{
	public static inline var BYTES_PER_ELEMENT = F32Array.SBYTES_PER_ELEMENT;

	public function new(inBufferOrArray:Dynamic, inStart:Int = 0, ?inElements:Null<Int>)
	{
		return new F32Array(inBufferOrArray, inStart, inElements);
	}
}

#elseif js

typedef Float32Array = js.lib.Float32Array;

#else

import haxe.Int32;

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
		throw "setInt32 is not supported on this target";
	}
}

#end

#end // !doc
