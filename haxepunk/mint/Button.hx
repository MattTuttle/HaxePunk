package haxepunk.mint;

import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.scene.*;
import mint.core.Macros.*;

class Button extends BaseRender
{

    public var color:Color;
    public var color_hover:Color;
    public var color_down:Color;

    public function new(render:HaxePunkMintRender, control:mint.Button)
    {
        super(render, control);

        var opt = control.options.options;

        color = def(opt.color, new Color().fromInt(0x373737));
        color_hover = def(opt.color_hover, new Color().fromInt(0x445158));
        color_down = def(opt.color_down, new Color().fromInt(0x444444));

        visual = new BoxShape(new Rectangle(0, 0, control.w, control.h));
        visual.color = opt.color == null ? new Color().fromInt(0x373737) : opt.color;
        entity.addGraphic(visual);

        control.onmouseenter.listen(function(e,c) { visual.color = color_hover; });
        control.onmouseleave.listen(function(e,c) { visual.color = color; });
        control.onmousedown.listen(function(e,c) { visual.color = color_down; });
        control.onmouseup.listen(function(e,c) { visual.color = color_hover; });
    }

    override public function onbounds()
    {
        super.onbounds();
        visual.rect.width = control.w;
        visual.rect.height = control.h;
    }

    private var visual:BoxShape;

}
