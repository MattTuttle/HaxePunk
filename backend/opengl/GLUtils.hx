package backend.opengl;

import haxepunk.utils.Log;
import haxe.PosInfos;
import backend.generic.render.Texture;

@:dox(hide)
class GLUtils
{


	public static inline function invalid(object:Any):Bool
	{
		#if js
		return object == null;
		#else
		return object == 0;
		#end
	}
}
