package haxepunk.debug;

import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.scene.*;
import haxepunk.utils.LibInfo;

typedef FrameInfo = {
	var frameRate:Float;
	var updateTime:Float;
	var renderTime:Float;
};

class Console
{

	public static var enabled:Bool = false;

	public static function log(line:String)
	{
		instance.lines.push(line);
		if (instance.lines.length > 500) instance.lines.shift();
	}

	private function new()
	{
		lines = [LibInfo.name + " " + LibInfo.fullVersion];
		_tool = new SelectTool();

		_frameInfos = new HistoryQueue<FrameInfo>(50);

		_logText = new Text(lines.join("\n"), 12);
		_logText.color.fromRGB(0.5, 0.5, 0.5);

		_fpsText = new Text("");
		_entityText = new Text("0 Entities");
	}

	public function update(scene:Scene, elapsed:Float):Void
	{
		_frameInfos.add({
			frameRate: Std.int(HXP.frameRate) / 100,
			updateTime: HXP.updateTime * 20,
			renderTime: HXP.renderTime * 150,
		});
		_logText.text = lines.join("\n") + "\n> " + input;
		_fpsText.text = "FPS: " + Std.int(HXP.frameRate);
		_entityText.text = scene.entityCount + (scene.entityCount == 1 ? " Entity" : " Entities");

		_tool.update(scene, elapsed);
	}

	public function draw(scene:Scene):Void
	{
		var pos = scene.camera.position;

		Draw.begin();

		_logText.origin.y = -(HXP.window.height - _logText.height);
		_logText.draw(pos);

		_fpsText.draw(pos);

		var x = HXP.window.width - _entityText.width;
		_entityText.origin.x = -x;
		Draw.fillRect(x + pos.x, pos.y, _entityText.width, _entityText.height, HXP.entityColor);
		_entityText.draw(pos);

		if (_frameInfos.length > 1)
		{
			var fpsColor = new Color(0.27, 0.54, 0.4);
			var updateColor = new Color(1.0, 0.94, 0.65);
			var renderColor = new Color(0.71, 0.29, 0.15);
			var x, y = pos.y + 50, w = 3, h = 30;
			var lastInfo:FrameInfo = null;
			for (i in 1..._frameInfos.length)
			{
				var info = _frameInfos.get(i);
				if (lastInfo != null)
				{
					x = pos.x + i * w;
					Draw.line(x, y - lastInfo.frameRate * h, x + w, y - info.frameRate * h, fpsColor);
					Draw.line(x, y - lastInfo.updateTime * h, x + w, y - info.updateTime * h, updateColor);
					Draw.line(x, y - lastInfo.renderTime * h, x + w, y - info.renderTime * h, renderColor);
				}
				lastInfo = info;
			}
		}

		var bounds:Rectangle;
		for (entity in scene.entities)
		{
			if (entity.mask != null)
			{
				entity.mask.debugDraw(entity.position, HXP.maskColor);
			}
			bounds = entity.bounds;
			Draw.rect(bounds.x, bounds.y, bounds.width, bounds.height, HXP.entityColor);
			Draw.pixel(entity.x, entity.y, HXP.entityColor, 4);
		}
		_tool.draw(pos);
	}

	@:allow(haxepunk.scene.Scene)
	private static var instance(get, null):Console;
	private static inline function get_instance():Console {
		if (instance == null)
		{
			instance = new Console();
		}
		return instance;
	}

	private var _frameInfos:HistoryQueue<FrameInfo>;
	private var _tool:Tool;
	private var _logText:Text;
	private var _fpsText:Text;
	private var _entityText:Text;
	private var lines:Array<String>;
	private var input:String = "";

}
