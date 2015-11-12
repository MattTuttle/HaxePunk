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

        color = def(opt.color, new Color().fromInt(0x373737));
        color_hover = def(opt.color_hover, new Color().fromInt(0x9dca63));

        visual = new Text(control.text);
        visual.color = color;
        entity.addGraphic(visual);

        control.onmouseenter.listen(function(e,c){ visual.color = color_hover; });
        control.onmouseleave.listen(function(e,c){ visual.color = color; });
    }

    function ontext(value:String)
    {
        visual.text = value;
    }

    private var visual:Text;

}
