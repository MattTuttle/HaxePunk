package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import mint.core.Macros.*;

class Canvas extends mint.render.Render
{

    public function new(render:HaxePunkMintRender, control:mint.Canvas)
    {
        super(render, control);

        var opt = control.options.options;

        visual = new BoxShape(new Rectangle(0, 0, control.w, control.h));
        visual.color = def(opt.color, new Color().fromInt(0x000c0c0c));
        entity = render.scene.addGraphic(visual, 0, control.x, control.y);
    }

    override function onbounds()
    {
        entity.x = control.x;
        entity.y = control.y;
    }

    private var visual:BoxShape;
    private var entity:Entity;

}
