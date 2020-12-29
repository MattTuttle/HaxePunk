package haxepunk.backend.html5;

import js.html.ImageData;
import js.Browser;
import js.lib.Promise;
import js.html.Image;
import js.html.CanvasElement;
import haxepunk.utils.Color;
import haxepunk.backend.opengl.GL;

@:build(haxepunk.backend.opengl.GLUtils.replaceGL())
class Texture implements haxepunk.backend.generic.render.Texture
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	var texture:GLTexture;
	var dirty:Bool = false;
	var pixels:ImageData;

	@:isVar static var canvas(get, null):CanvasElement;
	static function get_canvas():CanvasElement {
		if (canvas == null) canvas = cast Browser.document.createElement("canvas");
		return canvas;
	}

	public function new(data:ImageData, width:Int=0, height:Int=0)
	{
		#if !doc
		setSize(width, height);
		pixels = data;

		texture = gl.createTexture();
		#end
	}

	function setSize(width:Int, height:Int)
	{
		this.width = canvas.width = width;
		this.height = canvas.height = height;
	}

	public static function loadFromURL(path:String):Promise<Texture>
	{
		return new js.lib.Promise<Texture>(function(resolve, reject) {
			var image = new js.html.Image();
			image.onload = function() {
				var ctx = canvas.getContext2d();
				canvas.width = image.width;
				canvas.height = image.height;
				ctx.drawImage(image, 0, 0);
				var texture = new Texture(ctx.getImageData(0, 0, image.width, image.height), image.width, image.height);
				texture.dirty = true;

				resolve(texture);
			};
			image.onabort = function() {
				reject("Download was aborted");
			}
			image.src = path;
		});
	}

	public function getPixel(x:Int, y:Int):Color
	{
		var i = (y * width + x) * 4;
		var data = pixels.data;
		return Color.fromRGB(data[i+0], data[i+1], data[i+2]).withAlpha(data[i+3]);
	}

	public function setPixel(x:Int, y:Int, c:Color):Void
	{
		var i = (y * width + x) * 4;
		pixels.data[i+0] = c.r;
		pixels.data[i+1] = c.g;
		pixels.data[i+2] = c.b;
		pixels.data[i+3] = c.a;
		dirty = true;
	}

	// for removing background from bitmap fonts
	public function removeColor(color:Color):Void
	{
		var data = pixels.data;
		for (i in 0...(width * height))
		{
			if (data[i*4+0] == color.r && data[i*4+1] == color.g && data[i*4+2] == color.b)
			{
				data[i*4+3] = 0; // set alpha to zero
			}
		}
		dirty = true;
	}

	// used in Image.createCircle
	public function drawCircle(x:Float, y:Float, radius:Float):Void
	{
		var ctx = canvas.getContext2d();
		ctx.fillStyle = 'white';
		ctx.arc(x, y, radius, 0, Math.PI * 2);
		ctx.fill();
		dirty = true;
	}

	public function bind():Void
	{
		#if !doc
		gl.bindTexture(GL.TEXTURE_2D, texture);

		// check if the texture has changed and need to be uploaded to the gpu
		if (dirty)
		{
			gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, pixels);

			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.NEAREST);
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			dirty = false;
		}
		#end
	}

	public function dispose():Void
	{
		#if !doc
		gl.deleteTexture(texture);
		texture = null;
		canvas = null;
		#end
	}
}
