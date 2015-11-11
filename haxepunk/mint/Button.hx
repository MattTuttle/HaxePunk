package haxepunk.mint;

import haxepunk.graphics.*;
import haxepunk.math.*;
import mint.core.Macros.*;

class Button extends mint.render.Render
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
        Engine.scene.addGraphic(visual, 0, control.x, control.y);

        control.onmouseenter.listen(function(e,c) { visual.color = color_hover; });
        control.onmouseleave.listen(function(e,c) { visual.color = color; });
        control.onmousedown.listen(function(e,c) { visual.color = color_down; });
        control.onmouseup.listen(function(e,c) { visual.color = color_hover; });
    }

    private var visual:BoxShape;

}
