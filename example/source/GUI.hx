import haxepunk.*;
import haxepunk.inputs.*;
import haxepunk.graphics.*;
import haxepunk.utils.*;
import haxepunk.math.*;
import haxepunk.scene.*;
import haxepunk.mint.HaxePunkMintRender;

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

		var button = new mint.Button({
            parent: canvas,
            name: 'button1',
            x: 10, y: 52, w: 100, h: 32,
            text: 'mint',
            text_size: 14,
            options: { label: { color:new Color().fromInt(0x9dca63) } },
            onclick: function(e,c) {trace('mint button! ${Time.now}' );}
        });

		var scroll = new mint.Scroll({
			parent: window, name: 'scroll',
			x:10, y:30, w:236, h:236
		});

		new mint.Checkbox({
			parent: window, name: 'checkbox',
			x: 10, y: 280
		});

		new mint.Image({
            parent: scroll, name: 'icon_2',
            x:0, y:0, w:512, h:512,
            path: 'assets/lime.png'
        });

		var platform = new mint.Dropdown({
            parent: canvas,
            name: 'dropdown', text: 'Platform...',
            options: { color:new Color().fromInt(0x343439) },
            x:10, y:256, w:150, h:24,
        });

        var plist = ['windows', 'linux', 'ios', 'android', 'web'];

        inline function add_plat(name:String) {
            var first = plist.indexOf(name) == 0;
            platform.add_item(
                new mint.Label({
                    parent: platform, text: '$name',
                    name: 'plat-$name', w:125, h:24, text_size: 14
                }),
                10, (first) ? 0 : 10
            );
        }

        for(p in plist) add_plat(p);

		platform.onselect.listen(function(idx,_,_){ platform.label.text = plist[idx]; });
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

	override public function ready(window:Window)
	{
		window.scene.add(new GUIEntity());
		if (++numWindows < 2) addWindow(320, 240);
	}

	private var numWindows:Int = 0;

}
