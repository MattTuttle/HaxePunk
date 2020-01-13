package haxepunk.backend.opengl;

import haxepunk.utils.Log;
import haxe.PosInfos;
import haxepunk.backend.generic.render.Texture;

@:dox(hide)
class GLUtils
{

	public static inline function invalid(object:Any):Bool
	{
		#if nme
		return object == null || !object.isValid();
		#elseif (lime || js)
		return object == null;
		#else
		return object == 0;
		#end
	}
}
