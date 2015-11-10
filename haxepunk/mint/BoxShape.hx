package haxepunk.mint;

import haxepunk.math.*;
import haxepunk.graphics.*;

class BoxShape extends Graphic
{

    public var rect:Rectangle;
    public var color:Color;

    public function new(?rect:Rectangle, ?color:Color)
    {
        super();
        this.rect = rect == null ? new Rectangle() : rect;
        this.color = color == null ? new Color() : color;
    }

    override public function draw(batch:SpriteBatch, offset:Vector3)
    {
        Draw.begin(batch);
        Draw.fillRect(rect.x + offset.x, rect.y + offset.y, rect.width, rect.height, color);
    }
}
