package haxepunk.mint;

import haxepunk.scene.Entity;

class BaseRender extends mint.render.Render
{

    public function new(render:HaxePunkMintRender, control:mint.Control)
    {
        super(render, control);
        entity = new Entity(control.x, control.y, control.depth);
        entity.name = control.name;
        render.scene.add(entity);
    }

    override function ondestroy()
    {
        cast(rendering, HaxePunkMintRender).scene.remove(entity);
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
        entity.layer = depth;
    }

    private var entity:Entity;

}
