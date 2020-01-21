package haxepunk.backend.html5;

import js.Browser;
import js.lib.Promise;
import js.html.Image;
import js.html.webgl.GL;
import js.html.CanvasElement;
import haxepunk.backend.opengl.GLRenderer;
import haxepunk.utils.Color;

class Texture implements haxepunk.backend.generic.render.Texture
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	var canvas:CanvasElement;
	var texture:js.html.webgl.Texture;
	var dirty:Bool = false;

	public function new(width:Int=0, height:Int=0)
	{
		#if !doc
		canvas = cast Browser.document.createElement("canvas");
		setSize(width, height);

		texture = GLRenderer._GL.createTexture();
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
				texture.canvas.getContext("2d").drawImage(image, 0, 0);
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
		throw "getPixel Unimplemented";
	}

	public function setPixel(x:Int, y:Int, c:Color):Void
	{
		throw "setPixel Unimplemented";
	}

	// for removing background from bitmap fonts
	public function removeColor(color:Color):Void
	{
		throw "removeColor Unimplemented";
	}

	// used in Image.createCircle
	public function drawCircle(x:Float, y:Float, radius:Float):Void
	{
		var ctx = canvas.getContext("2d");
		ctx.fillStyle = 'white';
		ctx.arc(x, y, radius, 0, Math.PI * 2);
		ctx.fill();
		dirty = true;
	}

	public function bind():Void
	{
		#if !doc
		var _GL = GLRenderer._GL;
		_GL.bindTexture(GL.TEXTURE_2D, texture);

		// check if the texture has changed and need to be uploaded to the gpu
		if (dirty)
		{
			_GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, canvas);

			_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.NEAREST);
			_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}
		#end
	}

	public function dispose():Void
	{
		#if !doc
		GLRenderer._GL.deleteTexture(texture);
		texture = null;
		canvas = null;
		#end
	}
}
