package haxepunk.backend.hl;

#if hlsdl

import haxe.io.Path;
import haxepunk.HXP;
import haxepunk.utils.Log;
import haxepunk.graphics.Image;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.math.Vector2;
import haxepunk.graphics.text.TextOptions;
import haxepunk.graphics.text.BorderOptions;
import haxepunk.graphics.text.TextAlignType;

/**
 * Used for drawing text using embedded fonts.
 */
@:access(haxepunk.backend.hl.Texture)
class Text extends Image
{
	static var tag_re = ~/<([^>]+)>([^(<\/)]+)<\/[^>]+>/g;

	/**
	 * If the text field can automatically resize if its contents grow.
	 */
	public var resizable:Bool = true;

	/**
	 * Width of the text within the image.
	 */
	public var textWidth(default, null):Int = 0;

	/**
	 * Height of the text within the image.
	 */
	public var textHeight(default, null):Int = 0;

	/**
	 * Text string.
	 */
	public var text(default, set):String;
	function set_text(value:String):String
	{
		if (text == value && _richText == null) return value;
		text = value;
		//textWidth = Std.int(_source.canvas.getContext2d().measureText(text).width);
		_needsUpdate = true;
		return value;
	}

	/**
	 * Rich-text string with markup.
	 *
	 * Use `Text.addStyle` to control the appearance of marked-up text.
	 */
	public var richText(get, set):String;
	inline function get_richText():String return (_richText == null ? text : _richText);
	function set_richText(value:String):String
	{
		if (_richText == value) return value;
		var fromPlain = (_richText == null);
		_richText = value;
		if (_richText == "") text = "";
		if (fromPlain && _richText != null)
		{
			// _format.color = 0xFFFFFF;
		}
		else
		{
			_needsUpdate = true;
		}
		return value;
	}

	/**
	 * Font family.
	 */
	public var font(default, set):String;
	function set_font(value:String):String
	{
		if (font != value) _needsUpdate = true;
		return font = Path.withoutDirectory(Path.withoutExtension(value));
	}

	/**
	 * Font size.
	 */
	public var size(default, set):Int;
	function set_size(value:Int):Int
	{
		textHeight = value;
		if (size != value) _needsUpdate = true;
		return size = value;
	}

	/**
	 * Font alignment.
	 */
	public var align(default, set):TextAlignType;
	function set_align(value:TextAlignType):TextAlignType
	{
		if (align != value) _needsUpdate = true;
		return align = value;
	}

	/**
	 * Leading (amount of vertical space between lines).
	 */
	public var leading(default, set):Int;
	function set_leading(value:Int):Int
	{
		if (leading != value) _needsUpdate = true;
		return leading = value;
	}

	/**
	 * If set, configuration for text border.
	 */
	var border(default, set):Null<BorderOptions>;
	inline function set_border(options:Null<BorderOptions>):Null<BorderOptions>
	{
		_needsUpdate = true;
		return border = options;
	}

	var bufferMargin(get, null):Float;
	inline function get_bufferMargin() return 2 + (border == null ? 0 : border.size);

	/**
	 * Add a style for a subset of the text, for use with the richText property.
	 *
	 * Usage:
	 *
	 * ```
	 * text.addStyle("red", {color: 0xFF0000});
	 * text.addStyle("big", {size: text.size * 2, bold: true});
	 * text.richText = "<big>Hello</big> <red>world</red>";
	 * ```
	 */
	public function addStyle(tagName:String, params:Dynamic):Void
	{
		Log.critical("addStyle not working on js target");
		if (_richText != null) _needsUpdate = true;
	}

	override function get_width():Int return Std.int(_width);
	override function get_height():Int return Std.int(_height);

	/**
	 * Text constructor.
	 * @param text    Text to display.
	 * @param x       X offset.
	 * @param y       Y offset.
	 * @param width   Image width (leave as 0 to size to the starting text string).
	 * @param height  Image height (leave as 0 to size to the starting text string).
	 * @param options An object containing optional parameters contained in TextOptions
	 * 						font		Font family.
	 * 						size		Font size.
	 * 						align		Alignment (one of: TextFormatAlign.LEFT, TextFormatAlign.CENTER, TextFormatAlign.RIGHT, TextFormatAlign.JUSTIFY).
	 * 						wordWrap	Automatic word wrapping.
	 * 						resizable	If the text field can automatically resize if its contents grow.
	 * 						color		Text color.
	 * 						leading		Vertical space between lines.
	 *						richText	If the text field uses a rich text string
	 */
	public function new(text:String = "", x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, ?options:TextOptions)
	{

		if (options == null) options = {};

		// defaults
		if (!Reflect.hasField(options, "font")) options.font = HXP.defaultFont;
		if (!Reflect.hasField(options, "size")) options.size = 16;
		if (!Reflect.hasField(options, "align")) options.align = TextAlignType.LEFT;
		if (!Reflect.hasField(options, "color")) options.color = 0xFFFFFF;
		if (!Reflect.hasField(options, "resizable")) options.resizable = true;
		if (!Reflect.hasField(options, "wordWrap")) options.wordWrap = false;
		if (!Reflect.hasField(options, "leading")) options.leading = 0;
		if (!Reflect.hasField(options, "border")) options.border = null;

		resizable = options.resizable;

		var fontSize = options.size;

		var metrics = measureText(text);

		_width = (width == 0 ? Std.int(metrics + 4) : width);
		_height = (height == 0 ? Std.int(fontSize + 4) : height);

		_source = new Texture(null, _width, _height);
		_region = Atlas.loadImageAsRegion(_source);
		super();

		this.x = x;
		this.y = y;
		this.text = text;
		this.border = options.border;
		this.size = options.size;
		this.color = options.color;
		this.font = options.font;
		this.align = options.align;
		this._wordWrap = options.wordWrap;

		_needsUpdate = true;
	}

	function measureText(text:String):Int {
		return 0;
	}

	override public function render(point:Vector2, camera:Camera)
	{
		if (_needsUpdate)
		{
			_needsUpdate = false;

			var lines = [];

			if (_wordWrap)
			{
				for (words in text.split("\n")) {
					var line = "";
					for (word in words.split(" "))
					{
						var lineLength = measureText(line + " " + word);
						if (lineLength > _width) {
							lines.push(line);
							line = "";
						}
						line += word + " ";
					}
					lines.push(line);
				}
			}
			else
			{
				lines.push(text);
				textWidth = Std.int(measureText(text));

				if (resizable)
				{
					var width = Math.ceil(textWidth + (bufferMargin * 2));
					if (_width < width) _width = width;

					var height = Math.ceil(textHeight + (bufferMargin * 2));
					if (_height < height) _height = height;
				}
			}

			for (i in 0...lines.length) {
				var lineWidth = measureText(lines[i]);
				var x = switch (align) {
					case LEFT:
						0;
					case RIGHT:
						_width - (lineWidth / 2);
					case CENTER:
						_width / 2;
				}
				//ctx.fillText(lines[i], x, i * textHeight + bufferMargin);
			}

			// reset the source texture
			_source.width = _width;
			_source.height = _height;
			_source.dirty = true;
			_region = Atlas.loadImageAsRegion(_source);
		}
		super.render(point, camera);
	}

	// Text information.
	var _width:Int;
	var _height:Int;
	var _richText:String;
	var _source:Texture;
	var _wordWrap:Bool = false;

	var _needsUpdate:Bool = true;

	var _borderRegion:AtlasRegion;
}

#end