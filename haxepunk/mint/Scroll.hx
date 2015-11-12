package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import mint.core.Macros.*;

class Scroll extends BaseRender
{

    public function new(render:HaxePunkMintRender, control:mint.Scroll)
    {
        scroll = control;
        super(render, control);

        var opt = control.options.options;

        var color = def(opt.color, new Color().fromInt(0x343434));
        var color_handles = def(opt.color_handles, new Color().fromInt(0x9dca63));

        visual = new BoxShape(new Rectangle(0, 0, control.w, control.h));
        visual.color = color;
        entity.addGraphic(visual);

        var scrollh = new BoxShape(new Rectangle(0, 0, control.scrollh.w, control.scrollh.h));
        scrollh.color = color_handles;
        horiz = render.scene.addGraphic(scrollh, render.depth + control.scrollh.depth, control.scrollh.x, control.scrollh.y);

        var scrollv = new BoxShape(new Rectangle(0, 0, control.scrollv.w, control.scrollv.h));
        scrollv.color = color_handles;
        vert = render.scene.addGraphic(scrollv, render.depth + control.scrollv.depth, control.scrollv.x, control.scrollh.y);

        scroll.onchange.listen(onchange);
        scroll.onhandlevis.listen(onhandlevis);
    }

    override function onbounds()
    {
        super.onbounds();
        // scrollers
        horiz.x = scroll.scrollh.x;
        horiz.y = scroll.scrollh.y;
        vert.x = scroll.scrollv.x;
        vert.y = scroll.scrollv.y;
    }

    function onhandlevis(h:Bool, v:Bool)
    {
        horiz.drawable = h && scroll.visible;
        vert.drawable = v && scroll.visible;
    }

    override function onvisible(visible:Bool)
    {
        super.onvisible(visible);
        onhandlevis(scroll.visible_h, scroll.visible_v);
    }

    function onchange() {
        horiz.x = scroll.scrollh.x;
        vert.y = scroll.scrollv.y;
    }

    override function ondepth(depth:Float) {
        super.ondepth(depth);
        vert.layer = render.depth + scroll.scrollv.depth;
        horiz.layer = render.depth + scroll.scrollh.depth;
    }

    private var visual:BoxShape;
    private var horiz:Entity;
    private var vert:Entity;
    private var scroll:mint.Scroll;

}
