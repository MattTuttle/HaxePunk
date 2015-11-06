package haxepunk.scene;

import haxepunk.HXP;
import haxepunk.graphics.Color;
import haxepunk.math.*;
import haxepunk.utils.Time;

class Camera extends SceneNode
{

	/**
	 * The camera's viewport width.
	 */
	public var width:Float;

	/**
	 * The camera's viewport height.
	 */
	public var height:Float;

	/**
	 * Half the camera's width. Useful for centering.
	 */
	public var halfWidth(get, never):Float;
	private inline function get_halfWidth():Float { return width / 2; }

	/**
	 * Half the camera's height. Useful for centering.
	 */
	public var halfHeight(get, never):Float;
	private inline function get_halfHeight():Float { return height / 2; }

	/** The angle of the camera, in radians. */
	public var angle:Float = 0;

	/** Zoom factor, 0.5 = half ; 1 = normal ; 2 = twice ... */
	public var zoom:Float = 1;

	/**
	 * Clear (background) color.
	 */
	public var clearColor:Color;

	/**
	 * The camera's matrix transform.
	 */
	public var transform(default, null):Matrix4;

	public function new(width:Float, height:Float)
	{
		super();
		transform = new Matrix4();

		this.clearColor = new Color(0.117, 0.117, 0.117, 1.0);
		this.width = width;
		this.height = height;
	}

	public function make2D():Void
	{
		var invZoom = 1 / zoom; // invert for correct scaling
		_projection = Matrix4.createOrtho(0, width * invZoom, height * invZoom, 0, 500, -500);
	}

	public function make3D(fov:Float):Void
	{
		_projection = Matrix4.createPerspective(fov * Math.RAD, (width / height) / zoom, -100, 100);
	}

	public function lookAt(target:Vector3):Void
	{
		transform.lookAt(position, target, Vector3.Y_AXIS);
	}

	/**
	 * Cause the camera to shake for a specified length of time.
	 * @param magnitude  The amount to shake the camera in pixels, in all directions. Think of it like a radius.
	 * @param duration   The duration, in seconds, to shake the camera.
	 */
	public function shake(magnitude:Float, duration:Float):Void
	{
		_shakeMagnitude = magnitude;
		_shakeDuration = duration;
	}

	/**
	 * Stop the camera from shaking immediately.
	 */
	public function stopShake():Void
	{
		_shakeDuration = 0;
	}

	public function update():Void
	{
		if (_projection == null) make2D();

		transform.identity();
		transform.rotateZ(angle);
		transform.translate(-x, -y, -z);

		if (_shakeDuration > 0)
		{
			_shakeDuration -= Time.elapsed;
			transform.translate(
				Math.random(-_shakeMagnitude, _shakeMagnitude),
				Math.random(-_shakeMagnitude, _shakeMagnitude),
				0 // only shake on x and y axis
			);
		}

		transform.multiply(_projection);
	}

	private var _projection:Matrix4;
	private var _shakeMagnitude:Float;
	private var _shakeDuration:Float = 0;

}
