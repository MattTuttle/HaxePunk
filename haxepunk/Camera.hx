package haxepunk;

import flash.geom.Point;

/**
 * @since 4.0.0
 */
class Camera extends Point
{
	public var scale:Float = 1;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	public var fullScaleX(get, never):Float;
	inline function get_fullScaleX() return scale * scaleX * HXP.screen.fullScaleX;
	public var fullScaleY(get, never):Float;
	inline function get_fullScaleY() return scale * scaleY * HXP.screen.fullScaleY;

	public var width(get, never):Float;
	inline function get_width() return HXP.screen.width / fullScaleX;

	public var height(get, never):Float;
	inline function get_height() return HXP.screen.height / fullScaleY;

	/**
	 * Return an X value that, after scaling, will result in an integer.
	 */
	public inline function floorX(x:Float) return Math.floor(x * fullScaleX) / fullScaleX;
	/**
	 * Return a Y value that, after scaling, will result in an integer.
	 */
	public inline function floorY(y:Float) return Math.floor(y * fullScaleY) / fullScaleY;

	var anchorTarget:Null<Position>;
	var anchorX:Float = 0;
	var anchorY:Float = 0;

	/**
	 * Anchor the Camera to an Entity or other object with position. The
	 * Camera will keep the target in the specified part of the screen.
	 * @since 4.0.0
	 */
	public function anchor(?target:Position, anchorX:Float = 0.5, anchorY:Float = 0.5)
	{
		anchorTarget = target;
		this.anchorX = anchorX;
		this.anchorY = anchorY;
	}

	public function onCamera(entity:Entity):Bool
	{
		return entity.collideRect(entity.x, entity.y, x, y, HXP.width, HXP.height);
	}

	public function update()
	{
		if (anchorTarget != null)
		{
			var tx = anchorTarget.x,
				ty = anchorTarget.y;
			if (Std.is(anchorTarget, Entity))
			{
				var e:Entity = cast anchorTarget;
				tx += e.width / 2;
				ty += e.height / 2;
			}
			x = tx - (HXP.width * anchorX);
			y = ty - (HXP.height * anchorY);
		}

		// camera shake
		if (_shakeTime > 0)
		{
			var sx:Int = Std.random(_shakeMagnitude * 2 + 1) - _shakeMagnitude;
			var sy:Int = Std.random(_shakeMagnitude * 2 + 1) - _shakeMagnitude;

			x += sx - _shakeX;
			y += sy - _shakeY;

			_shakeX = sx;
			_shakeY = sy;

			_shakeTime -= HXP.elapsed;
			if (_shakeTime < 0) _shakeTime = 0;
		}
		else if (_shakeX != 0 || _shakeY != 0)
		{
			x -= _shakeX;
			y -= _shakeY;
			_shakeX = _shakeY = 0;
		}
	}

	/**
	 * Cause the camera to shake for a specified length of time.
	 * @param	duration	Duration of shake effect, in seconds.
	 * @param	magnitude	Number of pixels to shake in any direction.
	 * @since	2.5.3
	 */
	public function shake(duration:Float = 0.5, magnitude:Int = 4)
	{
		if (_shakeTime < duration) _shakeTime = duration;
		_shakeMagnitude = magnitude;
	}

	/**
	 * Stop the camera from shaking immediately.
	 * @since	2.5.3
	 */
	public function shakeStop()
	{
		_shakeTime = 0;
	}

	var _shakeTime:Float=0;
	var _shakeMagnitude:Int=0;
	var _shakeX:Int=0;
	var _shakeY:Int=0;
}
