package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import mint.core.Macros.*;

class Scroll extends BaseRender
{

    public function new(render:HaxePunkMintRender, control:mint.Scroll)
    {
        super(render, control);

        var opt = control.options.options;

        visual = new BoxShape(new Rectangle(0, 0, control.w, control.h));
        visual.color = def(opt.color, new Color().fromInt(0x000c0c0c));
        entity.addGraphic(visual);
    }

    private var visual:BoxShape;

}
