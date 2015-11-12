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

    override function onclip(disable:Bool, x:Float, y:Float, w:Float, h:Float)
    {
        if (disable)
        {
            visual.clipRect.x = visual.clipRect.y = 0;
            var texture = visual.material.firstPass.getTexture(0);
            visual.clipRect.width = texture.width;
            visual.clipRect.height = texture.height;
        }
        else
        {
            visual.clipRect.x = x;
            visual.clipRect.y = y;
            visual.clipRect.width = w;
            visual.clipRect.height = h;
        }
    }

    private var visual:haxepunk.graphics.Image;

}
