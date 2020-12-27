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

	var canvas:CanvasElement;
	var texture:GLTexture;
	var dirty:Bool = false;

	public function new(width:Int=0, height:Int=0)
	{
		#if !doc
		canvas = cast Browser.document.createElement("canvas");
		setSize(width, height);

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
				var texture = new Texture(image.width, image.height);
				texture.canvas.getContext2d().drawImage(image, 0, 0);
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
		var pixel = canvas.getContext2d().getImageData(x, y, 1, 1);
		return Color.fromRGB(pixel.data[0], pixel.data[1], pixel.data[2]).withAlpha(pixel.data[3]);
	}

	public function setPixel(x:Int, y:Int, c:Color):Void
	{
		var pixel = new ImageData(1, 1);
		pixel.data[0] = c.r;
		pixel.data[1] = c.g;
		pixel.data[2] = c.b;
		pixel.data[3] = c.a;
		canvas.getContext2d().putImageData(pixel, x, y);
		dirty = true;
	}

	// for removing background from bitmap fonts
	public function removeColor(color:Color):Void
	{
		var ctx = canvas.getContext2d();
		var pixels = ctx.getImageData(0, 0, width, height);
		var data = pixels.data;
		for (i in 0...(width * height))
		{
			if (data[i*4+0] == color.r && data[i*4+1] == color.g && data[i*4+2] == color.b)
			{
				data[i*4+3] = 0; // set alpha to zero
			}
		}
		ctx.putImageData(pixels, 0, 0);
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
			gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, canvas);

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
