package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.Entity;
import mint.core.Macros.*;

class Label extends mint.render.Render
{

    public var color_hover:Color;
    public var color:Color;

    public function new(render:HaxePunkMintRender, control:mint.Label)
    {
        super(render, control);
        var opt = control.options.options;

        color = def(opt.color, new Color().fromInt(0x373737));
        color_hover = def(opt.color_hover, new Color().fromInt(0x9dca63));

        text = new Text(control.text);
        text.color = color;
        entity = render.scene.addGraphic(text, 0, control.x, control.y);

        control.onmouseenter.listen(function(e,c){ text.color = color_hover; });
        control.onmouseleave.listen(function(e,c){ text.color = color; });
    }

    function ontext(value:String)
    {
        text.text = value;
    }

    override function onbounds()
    {
        entity.x = control.x;
        entity.y = control.y;
        // TODO: handle width/height?
    }

    override function onclip(disable:Bool, x:Float, y:Float, w:Float, h:Float)
    {

    }

    override function onvisible(visible:Bool)
    {
        entity.drawable = visible;
    }

    override function ondepth(depth:Float)
    {
        entity.layer = depth;
    }

    private var text:Text;
    private var entity:Entity;

}
