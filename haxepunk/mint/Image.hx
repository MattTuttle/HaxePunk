package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import mint.core.Macros.*;

class Image extends BaseRender
{

    public function new(render:HaxePunkMintRender, control:mint.Image)
    {
        super(render, control);

        var opt = control.options.options;

        visual = new haxepunk.graphics.Image(control.options.path);
        visual.width = control.w;
        visual.height = control.h;
        visual.tint = def(opt.color, new Color());
        entity.addGraphic(visual);
    }

    override function onbounds()
    {
        super.onbounds();
        visual.width = control.w;
        visual.height = control.h;
    }

    private var visual:haxepunk.graphics.Image;

}
