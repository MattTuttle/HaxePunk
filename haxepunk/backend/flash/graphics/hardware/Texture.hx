package haxepunk.backend.flash.graphics.hardware;

import haxepunk.utils.Color;

import haxepunk.backend.opengl.GLRenderer;
import flash.display.BitmapData;
import flash.geom.Point;

class Texture implements haxepunk.backend.generic.render.Texture
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	public function new(data:BitmapData)
	{
		this.data = data;
		width = data.width;
		height = data.height;
	}

	public inline function removeColor(color:Color)
	{
		data.threshold(data, data.rect, _zero, "==", color, 0x00000000, 0xFFFFFFFF, true);
	}

	public inline function clearColor(color:Color)
	{
		data.fillRect(data.rect, color);
	}

	public function drawCircle(x:Float, y:Float, radius:Float)
	{
		var sprite = new flash.display.Sprite();
		sprite.graphics.clear();
		sprite.graphics.beginFill(0xFFFFFF);
		sprite.graphics.drawCircle(x, y, radius);
		data.draw(sprite);
	}

	public function getPixel(x:Int, y:Int):Color
	{
		return data.getPixel(x, y);
	}

	public function setPixel(x:Int, y:Int, c:Color):Void
	{
		data.setPixel(x, y, c);
	}

	#if openfl

	#if (openfl >= "8.9.2")
	public static var renderer:openfl._internal.renderer.context3D.Context3DRenderer;
	#elseif (openfl >= "8.0.0")
	public static var renderer:openfl.display.OpenGLRenderer;
	public static var gl:WebGLRenderContext;
	#end

	#if (openfl < "8.9.2")
	@:access(openfl.display.OpenGLRenderer.__context3D)
	#end
	@:access(openfl.display.Stage)
	@:access(openfl.display3D.textures.TextureBase.__getTexture)
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	public function bind()
	{
		#if (openfl < "8.0.0")
		var renderer = @:privateAccess (HXP.app.stage.__renderer).renderSession;
		#end
		GL.bindTexture(GL.TEXTURE_2D, data.getTexture(
		#if (openfl < "8.9.2")
			renderer.__context3D
		#else
			renderer.context3D
		#end
		).__getTexture());
	}

	#elseif nme

	public function bind()
	{
		//if (!texture.premultipliedAlpha) texture.premultipliedAlpha = true;
		GL.bindBitmapDataTexture(data);
	}

	#end

	public function dispose():Void
	{
		data.dispose();
	}

	var data:BitmapData;
	static var _zero = new Point(0, 0);
}
