package haxepunk.mint;

import haxepunk.math.Rectangle;
import haxepunk.scene.Entity;

class BaseRender extends mint.render.Render
{

    public function new(render:HaxePunkMintRender, control:mint.Control)
    {
        this.render = render;
        super(render, control);
        entity = new Entity(control.x, control.y, render.depth + control.depth);
        entity.name = control.name;
        entity.drawable = control.visible;
        render.scene.add(entity);

        var clip = control.clip_with;
        if (clip != null)
        {
            onclip(false, clip.x, clip.y, clip.w, clip.h);
        }
    }

    override function onclip(disable:Bool, x:Float, y:Float, w:Float, h:Float)
    {
        if (disable)
        {
            entity.clipRect = null;
        }
        else
        {
            entity.clipRect = new Rectangle(x, y, w, h);
        }
    }

    override function ondestroy()
    {
        render.scene.remove(entity);
    }

    override function onbounds()
    {
        entity.x = control.x;
        entity.y = control.y;
    }

    override function onvisible(visible:Bool)
    {
        entity.drawable = visible;
    }

    override function ondepth(depth:Float)
    {
        entity.layer = render.depth + depth;
    }

    private var entity:Entity;
    private var render:HaxePunkMintRender;

}
