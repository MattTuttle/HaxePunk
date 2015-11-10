package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;

class Label extends mint.render.Render
{

    public function new(render:HaxePunkMintRender, control:mint.Label)
    {
        super(render, control);
        trace(control.text);
        text = new Text(control.text);
        var opt = control.options.options;
        if (opt.color != null) text.color = opt.color;
        Engine.scene.addGraphic(text, 0, control.x, control.y);
    }

    function ontext(text:String)
    {
        this.text.text = text;
    }

    private var text:Text;

}
