package haxepunk.graphics.text;

#if (lime || nme)

typedef Text = haxepunk.backend.flash.graphics.text.Text;

#elseif js

typedef Text = haxepunk.backend.html5.Text;

#else

#error "Text is not supported on this target"

#end
