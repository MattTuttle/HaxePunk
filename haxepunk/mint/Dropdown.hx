package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import mint.core.Macros.*;

class Dropdown extends BaseRender
{

    public function new(render:HaxePunkMintRender, control:mint.Dropdown)
    {
        super(render, control);

        var opt = control.options.options;

        visual = new BoxShape(new Rectangle(0, 0, control.w, control.h));
        visual.color = def(opt.color, new Color().fromInt(0x373737));
        entity.addGraphic(visual);

        border = new BoxShape(new Rectangle(0, 0, control.w, control.h));
        border.outline = true;
        border.color = def(opt.color_border, new Color().fromInt(0x121212));
        entity.addGraphic(border);
    }

    override function onbounds() {
        super.onbounds();
        visual.rect.width = control.w;
        visual.rect.height = control.h;
        border.rect.width = control.w+1;
        border.rect.height = control.h;
    }

    private var visual:BoxShape;
    private var border:BoxShape;

}
