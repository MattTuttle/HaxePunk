package haxepunk.scene;

import haxepunk.graphics.Color;
import haxepunk.math.*;
import haxepunk.utils.Time;

enum ScaleMode
{
	NoScale;
	Stretch;
	Zoom;
	LetterBox;
}

class Camera extends SceneNode
{

	/**
	 * The camera's viewport width.
	 * If you change this the projection must be updated to take effect!
	 */
	public var width:Float = 0;

	/**
	 * The camera's viewport height.
	 * If you change this the projection must be updated to take effect!
	 */
	public var height:Float = 0;

	/**
	 * Half the camera's width. Useful for centering.
	 */
	public var halfWidth(get, never):Float;
	private inline function get_halfWidth():Float { return width * 0.5; }

	/**
	 * Half the camera's height. Useful for centering.
	 */
	public var halfHeight(get, never):Float;
	private inline function get_halfHeight():Float { return height * 0.5; }

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

	/**
	 * Determines how the viewport should scale when drawing with this camera.
	 */
	public var scaleMode:ScaleMode = LetterBox;

	/**
	 * The window viewport.
	 */
	public var viewport(default, null):Rectangle;

	public function new(width:Float=0, height:Float=0)
	{
		super();
		transform = new Matrix4();
		viewport = new Rectangle();
		this.width = width;
		this.height = height;
	}

	public function setViewport(windowWidth:Float, windowHeight:Float):Rectangle
	{
		ortho(); // TODO: There MUST be a better way to do this!
		switch (scaleMode)
		{
			case NoScale:
				viewport.width = width;
				viewport.height = height;
			case Zoom, LetterBox:
				var scale = windowWidth / this.width;
				var dy = scale * this.height - windowHeight;
				if ((scaleMode == Zoom && dy < 0) ||
					(scaleMode == LetterBox && dy > 0))
				{
					scale = windowHeight / this.height;
				}
				viewport.width = width * scale;
				viewport.height = height * scale;
			case Stretch:
				viewport.width = windowWidth;
				viewport.height = windowHeight;
		}
		viewport.x = (windowWidth - viewport.width) / 2;
		viewport.y = (windowHeight - viewport.height) / 2;
		return viewport;
	}

	public function cameraToScreen(point:Vector3):Vector3
	{
		var result = transform * point;
		result.x = ((result.x + 1) / 2) * viewport.width + viewport.x;
		result.y = ((1 - result.y) / 2) * viewport.height + viewport.y;
		return result;
	}

	/**
	 * Convert screen to camera coordinates.
	 * @param point  The screen position to convert.
	 * @return The point in world/camera coordinates.
	 */
	public function screenToCamera(point:Vector3):Vector3
	{
		var result = new Vector3(
			2 * ((point.x - viewport.x) / viewport.width) - 1, // x coord (-1 to 1)
			1 - 2 * ((point.y - viewport.y) / viewport.height), // y coord (1 to -1) inverted because of OpenGL
			0
		);
		return transform.inverse() * result;
	}

	/**
	 * Change camera projection to orthographic.
	 * @param near  The near clipping plane.
	 * @param far  The far clipping plane.
	 */
	public function ortho(near:Float=500, far:Float=-500):Void
	{
		_projection = Matrix4.createOrtho(0, width, height, 0, near, far);
	}

	/**
	 * Change camera projection to perspective.
	 * @param fov  Field of view, in radians.
	 * @param near  The near clipping plane.
	 * @param far  The far clipping plane.
	 */
	public function perspective(fov:Float, near:Float=100, far:Float=-100):Void
	{
		_projection = Matrix4.createPerspective(fov, (width / height), near, far);
	}

	/**
	 * Transform camera to look at a position.
	 * @param target  The position to look at.
	 */
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

	/**
	 * Updates the camera's transform matrix.
	 */
	public function update(window:Window):Void
	{
		if (width == 0 || height == 0)
		{
			width = window.width;
			height = window.height;
			setViewport(width, height);
		}

		// reset transform
		transform.identity();
		transform.rotateZ(angle);
		transform.scale(zoom, zoom, zoom);

		// translate to position and then apply shake, if any.
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

		// apply projection
		transform.multiply(_projection);
	}

	private var _projection:Matrix4;
	private var _shakeMagnitude:Float;
	private var _shakeDuration:Float = 0;

}
