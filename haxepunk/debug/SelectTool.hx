package haxepunk.debug;

import haxepunk.graphics.Draw;
import haxepunk.inputs.*;
import haxepunk.math.*;
import haxepunk.scene.Scene;

class SelectTool implements Tool
{

	public function new()
	{
		_selectRect = new Rectangle();
	}

	public function update(window:Window)
	{
		var input = window.input,
			mouse = input.mouse;
		if (input.pressed(MouseButton.LEFT) > 0)
		{
			_mouseOriginX = _selectRect.x = mouse.x;
			_mouseOriginY = _selectRect.y = mouse.y;
			_selectRect.width = _selectRect.height = 0;
			_mousePressed = true;
		}
		else if (input.released(MouseButton.LEFT) > 0)
		{
			_mousePressed = false;
			var point = new Vector3(mouse.x, mouse.y);
			for (entity in window.scene.entities)
			{
				if (entity.collidePoint(point))
				{
					// TODO: handle selection of entity
				}
			}
		}
		else if (input.check(MouseButton.LEFT) && _mousePressed)
		{
			if (mouse.x < _mouseOriginX)
			{
				_selectRect.x = mouse.x;
				_selectRect.right = _mouseOriginX;
			}
			else
			{
				_selectRect.x = _mouseOriginX;
				_selectRect.right = mouse.x;
			}

			if (mouse.y < _mouseOriginY)
			{
				_selectRect.y = mouse.y;
				_selectRect.bottom = _mouseOriginY;
			}
			else
			{
				_selectRect.y = _mouseOriginY;
				_selectRect.bottom = mouse.y;
			}
		}
	}

	public function draw(cameraPosition:Vector3)
	{
		if (_mousePressed)
		{
			Draw.rect(_selectRect.x, _selectRect.y, _selectRect.width, _selectRect.height, Console.selectColor);
		}
	}

	private var _selectRect:Rectangle;
	private var _mouseOriginX:Float = 0;
	private var _mouseOriginY:Float = 0;
	private var _mousePressed:Bool = false;
}
