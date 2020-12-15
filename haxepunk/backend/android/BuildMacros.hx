package haxepunk.backend.android;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
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
                            public static function start() {
                                ${f.expr};
                            }
                        };
                        c.pack = ["haxepunk", "backend", "android"];
                        c.meta.push({name: ":keep", pos: Context.currentPos()});
                        Context.defineType(c);
                        break;
                    }
                default:
            }
        }
        return fields;
    }
}