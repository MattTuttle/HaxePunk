package haxepunk.backend.android;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
#end

class BuildMacros
{
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        for (field in fields) {
            switch(field.kind) {
                case FFun(f):
                    if (field.name == "main") {
                        var c = macro class HaxePunkMain {
                            public static function start(assets:AssetLoader.AssetManager):App.GLSurfaceRenderer {
                                AssetLoader.assets = assets;
                                ${f.expr};
                                return cast HXP.app;
                            }
                        };
                        c.pack = ["haxepunk", "backend", "android"];
                        Context.defineType(c);
                        //fields.remove(field);
                        break;
                    }
                default:
            }
        }
        return fields;
    }
}