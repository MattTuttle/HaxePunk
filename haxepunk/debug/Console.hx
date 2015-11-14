package haxepunk.debug;

import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.scene.*;
import haxepunk.utils.*;

class Console
{

	// default colors
	public static var entityColor:Color = new Color(1, 0, 0, 0.3);
	public static var maskColor:Color = new Color(0, 1, 0, 0.3);
	public static var selectColor:Color = new Color(0.9, 0.9, 0.9);

	public var enabled:Bool = false;

	@:allow(haxepunk.Window)
	private function new()
	{
		_lines = [LibInfo.name + " " + LibInfo.fullVersion];
		_tool = new SelectTool();
		_statistics = new Array<Statistic>();

		_logText = new Text(_lines.join("\n"), 12);
		_logText.color.fromRGB(0.5, 0.5, 0.5);

		_fpsText = new Text("");
		_entityText = new Text("0 Entities");

		// set up a separate batch for the console
		_spriteBatch = new SpriteBatch();
		_camera = new Camera(0, 0);
	}

	public function log(line:String)
	{
		_lines.push(line);
		if (_lines.length > 500) _lines.shift();
	}

	public function addStat(stat:Statistic):Void
	{
		_statistics.push(stat);
	}

	public function update(window:Window):Void
	{
		var scene = window.scene;
		if (window.width != _camera.width || window.height != _camera.height)
		{
#if tvos
			// tv safe zone
			_camera.width = window.width - 180;
			_camera.height = window.height - 120;
			_camera.x = 90;
			_camera.y = 60;
#else
			_camera.width = window.width;
			_camera.height = window.height;
#end
			_camera.ortho();
			_camera.update();
		}
		_logText.text = _lines.join("\n") + "\n> " + _input;
		_fpsText.text = "FPS: " + Std.int(window.fps);
		var entities = scene.entityCount;
		_entityText.text = entities + (entities == 1 ? " Entity" : " Entities");

		_tool.update(window);
	}

	public function draw(window:Window):Void
	{
		var scene = window.scene;
		Draw.begin(scene.spriteBatch);
		var bounds:Rectangle;
		for (entity in scene.entities)
		{
			if (entity.mask != null)
			{
				entity.mask.debugDraw(entity.position, Console.maskColor);
			}
			bounds = entity.bounds;
			Draw.rect(bounds.x, bounds.y, bounds.width, bounds.height, Console.entityColor);
			Draw.pixel(entity.x, entity.y, Console.entityColor, 4);
		}
		Draw.end();

		var pos = _camera.position;
		_spriteBatch.begin(_camera.transform);
		Draw.begin(_spriteBatch);

		for (stat in _statistics) stat.draw();

		var x = _camera.width - _entityText.width;
		_entityText.origin.x = -x;
		Draw.fillRect(x + pos.x, pos.y, _entityText.width, _entityText.height, Console.entityColor);
		_entityText.draw(_spriteBatch, pos);

		_logText.origin.y = -(_camera.height - _logText.height);
		_logText.draw(_spriteBatch, pos);

		_fpsText.draw(_spriteBatch, pos);

		/*if (_frameInfos.length > 1)
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
				}
				lastInfo = info;
			}
		}*/

		_tool.draw(pos);
		_spriteBatch.end();
	}

	private var _camera:Camera;
	private var _spriteBatch:SpriteBatch;
	private var _statistics:Array<Statistic>;

	private var _tool:Tool;
	private var _logText:Text;
	private var _fpsText:Text;
	private var _entityText:Text;
	private var _lines:Array<String>;
	private var _input:String = "";

}
