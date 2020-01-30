package haxepunk.backend.opengl;


#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

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

	#if macro

	static function replaceGLLoop(e:Expr)
	{
		var flash = Context.defined("lime") || Context.defined("nme");
		var html5 = Context.defined("js") && !flash;
		switch (e.expr)
		{
			case EConst(CIdent("gl")):
				if (html5)
				{
					e.expr = EField(macro haxepunk.backend.html5.App, "gl");
				}
				else
				{
					e.expr = EConst(CIdent("GL"));
				}
			default:
				haxe.macro.ExprTools.iter(e, replaceGLLoop);
		}
	}

	/**
	 * Replace gl variable with correct OpenGL context depending on target
	 */
	public static function replaceGL()
	{
		var fields = Context.getBuildFields();
		for (f in fields)
		{
			switch (f.kind)
			{
				case FFun(f):
					if (f.expr != null) replaceGLLoop(f.expr);
				case FVar(_, e):
					if (e != null) replaceGLLoop(e);
				default:
			}
		}
		return fields;
	}
	#end
}
