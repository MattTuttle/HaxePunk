package haxepunk.graphics;

import haxepunk.*;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.math.Rectangle;
import haxepunk.scene.Camera;

abstract ImageSource(Material) to Material from Material
{
	private function new(material:Material) { this = material; }

	@:from
	static inline private function fromAsset(asset:String):ImageSource
	{
		var material = new Material();
		material.firstPass.addTexture(Assets.getTexture(asset));
		return new ImageSource(material);
	}
}

/**
 * A basic Image. Supports a clipping rectangle and flipping on the x and y axis.
 */
class Image extends Graphic
{

	/**
	 * Flip image on the x-axis
	 */
	public var flipX:Bool = false;

	/**
	 * Flip image on the y-axis
	 */
	public var flipY:Bool = false;

	/**
	 * Tint color and alpha
	 */
	public var tint:Color;

	/**
	 * Clipping rectangle used to only render a portion of the full texture.
	 * The rectangle should be set in pixel values and not uv values.
	 * Also sets the width/height values when changed.
	 */
	public var clipRect(default, set):Rectangle;
	private inline function set_clipRect(value:Rectangle):Rectangle
	{
		width = value.width;
		height = value.height;
		return clipRect = value;
	}

	/**
	 * Changes the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(get, set):Float;
	private inline function get_alpha():Float { return tint.a; }
	private function set_alpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		return (tint.a == value) ? value : tint.a = value;
	}

	/**
	 * Creates a new Image graphic.
	 * @param source The source image which can be an asset string or a Material object
	 * @param clipRect the default clipping rectangle
	 */
	public function new(source:ImageSource, ?clipRect:Rectangle)
	{
		super();

		tint = new Color(); // white

#if !unit_test
		this.material = source;
		var texture = this.material.firstPass.getTexture(0);
		if (texture == null) throw "Must have a texture attached for materials used in " + Type.getClassName(Type.getClass(this));

		this.clipRect = (clipRect == null ? new Rectangle(0, 0, texture.width, texture.height) : clipRect);
#end
	}

	/**
	 * Renders the image using sprite batching
	 * @param offset the image offset value typically passed from an Entity object
	 */
	override public function draw(offset:Vector3):Void
	{
		SpriteBatch.draw(material, offset.x - origin.x, offset.y - origin.y, width, height,
			clipRect.x, clipRect.y, clipRect.width, clipRect.height,
			flipX, flipY, origin.x, origin.y, scale.x, scale.y, angle, tint);
	}

}
