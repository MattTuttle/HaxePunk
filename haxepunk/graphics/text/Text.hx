package haxepunk.graphics.text;

#if (lime || nme)

typedef Text = haxepunk.backend.flash.graphics.text.Text;

#elseif js

typedef Text = haxepunk.backend.html5.Text;

#elseif hl

typedef Text = haxepunk.backend.hl.Text;

#elseif unit_test

class Text extends Image {
    public var size:Int = 0;
    public var text:String;
    public function new(text:String, ?x, ?y, ?w, ?h, ?options) super();
}

#elseif !doc

#error "Text is not supported on this target"

#end
