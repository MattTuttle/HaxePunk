package haxepunk.graphics;

import haxe.ds.IntMap;
import haxepunk.scene.Camera;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.text.TextLayout;

using StringTools;

typedef GlyphImages = Map<lime.text.Glyph, lime.graphics.Image>;

class Font
{

	public var font(default, null):lime.text.Font;

	public static function fromFile(asset:String)
	{
		if (_fonts.exists(asset))
		{
			return _fonts.get(asset);
		}
		else
		{
			var font = new Font(asset);
			_fonts.set(asset, font);
			return font;
		}
	}

	private function new(asset:String)
	{
		this.font = lime.Assets.getFont(asset);
		_sizes = new Map<Int, GlyphImages>();
		_textures = new Map<Int, Texture>();
	}

	private function loadGlyphs(size:Int):Void
	{
		if (font == null) return;
		var images = font.renderGlyphs(font.getGlyphs(), size);
		if (images == null)
		{
			throw "Failed to load font glyphs";
		}
		// only load the first "image" since they all share the same buffer
		var it = images.iterator();
		if (it.hasNext())
		{
			var texture = new Texture();
			texture.loadFromImage(it.next());
			_textures.set(size, texture);
		}
		_sizes.set(size, images);
	}

	public function getTexture(size:Int):Texture
	{
		if (!_textures.exists(size))
		{
			loadGlyphs(size);
		}
		return _textures.get(size);
	}

	public function getGlyphs(size:Int):GlyphImages
	{
		if (!_sizes.exists(size))
		{
			loadGlyphs(size);
		}
		return _sizes.get(size);
	}

	private var _sizes:Map<Int, GlyphImages>;
	private var _textures:Map<Int, Texture>;
	private static var _fonts = new Map<String, Font>();
}

class Text extends Graphic
{

	public static var defaultFont:String = "hxp/font/OpenSans-Regular.ttf";

	/**
	 * The font color of the Text
	 */
	public var color:Color;

	/**
	 * The pixel height of each line of text
	 */
	public var lineHeight:Float;

	/**
	 * The number of spaces for tab characters
	 */
	public var tabWidth:Int = 4;

	/**
	 * The font size of the Text
	 */
	public var size(default, set):Int;
	private function set_size(value:Int):Int {
		if (size != value)
		{
			// TODO: change texture
			_images = _font.getGlyphs(value);
			if (_texture != null)
			{
				material.firstPass.removeTexture(_texture);
			}
			_texture = _font.getTexture(value);
			material.firstPass.addTexture(_texture);
		}
		return size = value;
	}

	/**
	 * The text value to render. Regenerates a list of glyphs to draw.
	 */
	public var text(default, set):String;
	private function set_text(value:String):String {
		if (text != value)
		{
			// replace tabs with appropriate spaces
			var tab = "";
			for (i in 0...tabWidth) tab += " ";
			value = value.replace("\t", tab);

			_textLayout.text = value;
		}
		return text = value;
	}

	/**
	 * Create a new Text graphic
	 * @param text the default text to render
	 * @param size the font size of the text
	 */
	public function new(text:String, size:Int=14)
	{
		super();
		color = new Color();

		#if flash
		var vert = "m44 op, va0, vc0\nmov v0, va1";
		var frag = "tex ft0, v0, fs0 <linear nomip 2d wrap>\nmov ft0.xyz, fc1.xyz\nmov oc, ft0";
		#else
		_font = Font.fromFile(defaultFont);
		_textLayout = new TextLayout("", _font.font, size, LEFT_TO_RIGHT, LATIN, "en");
		_texture = _font.getTexture(size);

		var vert = Assets.getText("hxp/shaders/default.vert");
		var frag = Assets.getText("hxp/shaders/text.frag");
		#end

		var shader = new Shader(vert, frag);
		material = new Material();
		var pass = material.firstPass;
		pass.shader = shader;

		// Must be set AFTER material is created
		this.lineHeight = this.size = size;
		this.text = text;
	}

	/**
	 * Draw the Text object to the screen
	 * @param offset the offset of the Text object usually set from and Entity
	 */
	override public function draw(batch:SpriteBatch, offset:Vector3):Void
	{
		// hoisted variables
		var x:Float, y:Float, line:String, image;
		// TODO: handle carriage return!!
		var lines = text.split("\n");
		batch.material = material;
		var delta = offset - origin;
		for (i in 0...lines.length)
		{
			line = lines[i];
			// TODO: remove magic number (lineHeight * 0.8)
			y = lineHeight * i + lineHeight * 0.8;
			x = 0.0;
			for (p in _textLayout.positions)
			{
				image = _images.get(p.glyph);
				if (image != null)
				{
					batch.draw(material,
						delta.x + x + p.offset.x + image.x,
						delta.y + y + p.offset.y - image.y,
						image.width, image.height,
						image.offsetX, image.offsetY, image.width, image.height,
						false, false, origin.x, origin.y, scale.x, scale.y, 0, color);
				}

				x += p.advance.x;
				y -= p.advance.y;
			}
			if (x > width) width = x;
		}
		height = lineHeight * lines.length;
	}

	private var _textLayout:TextLayout;
	private var _font:Font;
	private var _texture:Texture;
	private var _images:GlyphImages;

}
