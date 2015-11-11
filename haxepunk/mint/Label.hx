package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;
import haxepunk.scene.Entity;

class Label extends mint.render.Render
{

    public function new(render:HaxePunkMintRender, control:mint.Label)
    {
        super(render, control);
        var opt = control.options.options;

        text = new Text(control.text);
        if (opt.color != null) text.color = opt.color;
        entity = render.scene.addGraphic(text, 0, control.x, control.y);
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
