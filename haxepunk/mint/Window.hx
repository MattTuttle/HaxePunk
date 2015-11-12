package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.scene.*;
import haxepunk.graphics.*;
import mint.core.Macros.*;

class Window extends BaseRender
{

    public function new(render:HaxePunkMintRender, control:mint.Window)
    {
        super(render, control);
        var opt = control.options.options;

        var color = def(opt.color, new Color().fromInt(0x242424));
        var color_border = def(opt.color_border, new Color().fromInt(0x373739));
        var color_titlebar = def(opt.color_titlebar, new Color().fromInt(0x373737));
        var color_collapse = def(opt.color_collapse, new Color().fromInt(0x666666));

        var windowRect = new Rectangle(0, 0, control.w, control.h);
        window = new BoxShape(windowRect, color);
        entity.addGraphic(window);

        titlebar = new BoxShape(new Rectangle(control.title.x - control.x, control.title.y - control.y, control.title.w, control.title.h), color_titlebar);
        entity.addGraphic(titlebar);

        border = new BoxShape(windowRect, color_border);
        border.outline = true;
        entity.addGraphic(border);
    }

    override function onbounds()
    {
        super.onbounds();
        var wind:mint.Window = cast control;
        border.rect.width = window.rect.width = wind.w;
        border.rect.height = window.rect.height = wind.h;

        titlebar.rect.x = wind.title.x - wind.x;
        titlebar.rect.y = wind.title.y - wind.y;
        titlebar.rect.width = wind.title.w;
        titlebar.rect.height = wind.title.h;
    }

    private var window:BoxShape;
    private var border:BoxShape;
    private var titlebar:BoxShape;

}
