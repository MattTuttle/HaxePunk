package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import mint.core.Macros.*;

class Label extends BaseRender
{

    public var color_hover:Color;
    public var color:Color;

    public function new(render:HaxePunkMintRender, control:mint.Label)
    {
        super(render, control);
        var opt = control.options.options;

        color = def(opt.color, new Color().fromInt(0xffffff));
        color_hover = def(opt.color_hover, new Color().fromInt(0x9dca63));

        visual = new Text(control.text);
        switch (control.options.align)
        {
            case center: visual.align = Center;
            case right: visual.align = Right;
            default: visual.align = Left;
        }
        switch (control.options.align_vertical)
        {
            case center: visual.verticalAlign = Middle;
            case bottom: visual.verticalAlign = Bottom;
            default: visual.verticalAlign = Top;
        }
        onbounds();
        visual.color = color;
        entity.addGraphic(visual);

        control.onchange.listen(function(value:String) {
            visual.text = value;
        });

        control.onmouseenter.listen(function(e,c){ visual.color = color_hover; });
        control.onmouseleave.listen(function(e,c){ visual.color = color; });
    }

    override function onbounds()
    {
        super.onbounds();
        visual.width = control.w;
        visual.height = control.h;
    }

    private var visual:Text;

}
