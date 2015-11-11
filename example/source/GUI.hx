import haxepunk.Engine;
import haxepunk.mint.*;
import haxepunk.inputs.*;
import haxepunk.graphics.*;
import haxepunk.utils.*;
import haxepunk.math.*;
import haxepunk.scene.*;

class GUIEntity extends Entity
{
	public function new()
	{
		super();
	    rendering = new HaxePunkMintRender();

		canvas = new mint.Canvas({
            name:'canvas',
            rendering: rendering,
            options: { color:new Color(1, 1, 1, 0.0) },
            x: 0, y:0, w: 960, h: 640
        });

		var window = new mint.Window({
			parent: canvas,
			name: 'window1',
			title: 'window',
			options: {
				color: new Color().fromInt(0x242424),
				color_titlebar: new Color().fromInt(0x373739)
			},
			x:160, y:10, w: 256, h: 400,
			w_min: 256, h_min:256,
			collapsible:true
		});
	}

	override private function set_scene(value:Scene):Scene {
		rendering.scene = value;
		return super.set_scene(value);
	}

	override public function draw(batch:SpriteBatch)
	{
		super.draw(batch);
		canvas.render();
	}

	override public function update()
	{
		var pos = scene.camera.screenToCamera(Mouse.position);
		var event:mint.types.Types.MouseEvent = {
			timestamp: Time.now,
			x: Std.int(pos.x),
			y: Std.int(pos.y),
			xrel: Std.int(last.x - pos.x),
			yrel: Std.int(last.y - pos.y),
			button: Input.check(MouseButton.LEFT) ? left : none,
			state: none, // isn't used...
			bubble: false // not used...
		};
		if (Input.pressed(MouseButton.LEFT) > 0)
		{
			canvas.mousedown(event);
		}
		else if (Input.released(MouseButton.LEFT) > 0)
		{
			canvas.mouseup(event);
		}
		canvas.mousemove(event);
		last = pos;

		canvas.update(Time.elapsed);
	}

	private var last:Vector3 = Vector3.ZERO;
	private var canvas:mint.Canvas;
	private var rendering:HaxePunkMintRender;

}

class GUI extends Engine
{
	override public function ready()
	{
		Engine.scene.add(new GUIEntity());
	}
}