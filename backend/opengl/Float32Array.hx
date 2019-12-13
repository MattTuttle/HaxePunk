package backend.opengl;

import haxe.Int32;

#if cpp
typedef Float32 = cpp.Float32;
#elseif hl
typedef Float32 = hl.F32;
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
