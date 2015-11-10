package haxepunk.mint;

import haxepunk.math.*;

class Window extends mint.render.Render
{

    public function new(render:HaxePunkMintRender, control:mint.Window)
    {
        super(render, control);
        var opt = control.options.options;

        var e = new haxepunk.scene.Entity();

        window = new BoxShape(new Rectangle(control.x, control.y, control.w, control.h), opt.color);
        e.addGraphic(window);

        titlebar = new BoxShape(new Rectangle(control.title.x, control.title.y, control.title.w, control.title.h), opt.color_titlebar);
        e.addGraphic(titlebar);

        Engine.scene.add(e);
    }

    override function onbounds()
    {
        trace("hi");
        var wind:mint.Window = cast control;
        window.rect.x = wind.x;
        window.rect.y = wind.y;
        window.rect.width = wind.w;
        window.rect.height = wind.h;

        titlebar.rect.x = wind.title.x;
        titlebar.rect.y = wind.title.y;
        titlebar.rect.width = wind.title.w;
        titlebar.rect.height = wind.title.h;
    }

    private var window:BoxShape;
    private var titlebar:BoxShape;

}
