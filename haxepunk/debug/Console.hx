package haxepunk.debug;

import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.scene.*;
import haxepunk.utils.*;
import haxepunk.inputs.*;

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

		if (window.input.pressed(Key.C) > 0)
		{
			_tool = new CameraTool();
		}
		else if (window.input.pressed(Key.S) > 0)
		{
			_tool = new SelectTool();
		}

		_tool.update(window);
	}

	public function draw(window:Window):Void
	{
		if (_spriteBatch == null)
		{
			_spriteBatch = new SpriteBatch();
		}
		// use the scene spritebatch to draw with correct camera transform
		Draw.begin(window.scene.spriteBatch);
		var bounds:Rectangle;
		for (entity in window.scene.entities)
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

		// reset spritebatch to correct camera position
		_spriteBatch.begin(window.renderer, _camera.transform);

		var pad = 4;
		var pos = new Vector3(); // TODO: remove unnecessary creation of vector
		_fpsText.draw(_spriteBatch, pos);

		pos.x = _camera.width - _entityText.width;
		Draw.begin(_spriteBatch);
		Draw.fillRect(pos.x - pad, 0, _entityText.width + pad, _entityText.height + pad, Console.entityColor);
		_entityText.draw(_spriteBatch, pos);

		pos.x = 0;
		pos.y = _camera.height - _logText.height;
		_logText.draw(_spriteBatch, pos);

		Draw.begin(_spriteBatch);
		for (stat in _statistics) stat.draw(_statRect);

		_tool.draw(pos);
		_spriteBatch.end();
	}

	private var _camera:Camera;
	private var _spriteBatch:SpriteBatch;

	private var _statistics:Array<Statistic>;
	private var _statRect = new Rectangle(0, 0, 200, 100);

	private var _tool:Tool;
	private var _logText:Text;
	private var _fpsText:Text;
	private var _entityText:Text;
	private var _lines:Array<String>;
	private var _input:String = "";

}
