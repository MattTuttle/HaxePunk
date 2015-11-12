package haxepunk.mint;

import mint.Control;
import mint.types.Types;

class HaxePunkMintRender extends mint.render.Rendering
{

    public var scene:haxepunk.scene.Scene;
    public var depth:Float = 0;

    public function new()
    {
        super();
        scene = Engine.scene;
    }

    override function get<T:Control, T1>( type:Class<T>, control:T ) : T1 {
        return cast switch(type) {
            case mint.Canvas:       new haxepunk.mint.Panel(this, cast control);
            case mint.Label:        new haxepunk.mint.Label(this, cast control);
            case mint.Window:       new haxepunk.mint.Window(this, cast control);
            case mint.Panel:        new haxepunk.mint.Panel(this, cast control);
            case mint.Button:       new haxepunk.mint.Button(this, cast control);
            case mint.Image:        new haxepunk.mint.Image(this, cast control);
            case mint.Scroll:       new haxepunk.mint.Scroll(this, cast control);
            /*case mint.List:         new haxepunk.mint.List(this, cast control);
            case mint.Checkbox:     new haxepunk.mint.Checkbox(this, cast control);
            case mint.TextEdit:     new haxepunk.mint.TextEdit(this, cast control);
            case mint.Dropdown:     new haxepunk.mint.Dropdown(this, cast control);
            case mint.Slider:       new haxepunk.mint.Slider(this, cast control);
            case mint.Progress:     new haxepunk.mint.Progress(this, cast control);*/
            default:                null;
        }
    }

}
