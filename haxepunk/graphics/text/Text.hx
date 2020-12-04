package haxepunk.graphics.text;

#if (lime || nme)

typedef Text = haxepunk.backend.flash.graphics.text.Text;

#elseif js

typedef Text = haxepunk.backend.html5.Text;

#elseif hl

typedef Text = haxepunk.backend.hl.Text;

#elseif !doc

#error "Text is not supported on this target"

#end
