package haxepunk.mint;

import haxepunk.math.*;

class Canvas extends mint.render.Render
{

    public function new(render:HaxePunkMintRender, control:mint.Canvas)
    {
        super(render, control);
        var box = new BoxShape(new Rectangle(0, 0, control.w, control.h));
        box.color = control.options.options.color;
        Engine.scene.addGraphic(box, 0, control.x, control.y);
    }

}
