package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.*;
import mint.core.Macros.*;

class Checkbox extends BaseRender
{

    public var color:Color;
    public var color_hover:Color;
    public var color_node:Color;
    public var color_node_hover:Color;

    public function new(render:HaxePunkMintRender, control:mint.Checkbox)
    {
        super(render, control);

        var opt = control.options.options;

        color = def(opt.color, new Color().fromInt(0x373737));
        color_hover = def(opt.color_hover, new Color().fromInt(0x445158));
        color_node = def(opt.color_node, new Color().fromInt(0x9dca63));
        color_node_hover = def(opt.color_node_hover, new Color().fromInt(0xadca63));

        visual = new BoxShape(new Rectangle(0, 0, control.w, control.h), color);
        entity.addGraphic(visual);

        node = new BoxShape(new Rectangle(4, 4, control.w-8, control.h-8), color_node);
        entity.addGraphic(node);

        control.onmouseenter.listen(function(e,c) {
            node.color.r = color_node_hover.r;
            node.color.g = color_node_hover.g;
            node.color.b = color_node_hover.b;
            visual.color = color_hover;
        });
        control.onmouseleave.listen(function(e,c) {
            node.color.r = color_node.r;
            node.color.g = color_node.g;
            node.color.b = color_node.b;
            visual.color = color;
        });

        control.onchange.listen(function(n,o) {
            node.color.a = n ? 1 : 0.25;
        });
    }

    private var visual:BoxShape;
    private var node:BoxShape;

}
