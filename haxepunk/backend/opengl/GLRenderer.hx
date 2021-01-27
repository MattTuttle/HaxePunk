package haxepunk.backend.opengl;

#if !doc

import haxe.PosInfos;
import haxe.ds.IntMap;
import haxepunk.utils.Color;
import haxepunk.backend.generic.render.Renderer;
import haxepunk.backend.generic.render.Texture;
import haxepunk.backend.opengl.GL;
import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.graphics.shader.Shader;
import haxepunk.graphics.hardware.DrawCommand;
import haxepunk.utils.BlendMode;

@:dox(hide)
typedef FrameBuffer = {
	texture:Null<GLTexture>,
	framebuffer:GLFramebuffer,
	width:Int,
	height:Int
}

/**
 * OpenGL-based renderer. Based on work by @Yanrishatum and @Beeblerox.
 * @since	2.6.0
 */
@:access(haxepunk.Scene)
@:access(haxepunk.Engine)
@:allow(haxepunk.debug)
@:access(haxepunk.backend.opengl)
@:build(haxepunk.backend.opengl.GLUtils.replaceGL())
class GLRenderer implements Renderer
{
	public static inline var UNIFORM_MATRIX:String = "uMatrix";

	static var _tracking:Bool = true;
	static var _shaders = new IntMap<CompiledShader>();

	static inline function ortho(x0:Float, x1:Float, y0:Float, y1:Float)
	{
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		_ortho[0] = 2.0 * sx;
		_ortho[5] = 2.0 * sy;
		_ortho[12] = -(x0 + x1) * sx;
		_ortho[13] = -(y0 + y1) * sy;
	}

	public static inline function bufferData(target, size, srcData, usage:Int)
	{
		#if hl
		gl.bufferData(target, size, srcData, usage);
		#elseif (html5 && lime >= "5.0.0")
		gl.bufferDataWEBGL(target, srcData, usage);
		#elseif (java || lime >= "4.0.0")
		gl.bufferData(target, size, srcData, usage);
		#else
		gl.bufferData(target, srcData, usage);
		#end
		checkForErrors();
	}

	public static inline function bufferSubData(buffer:BufferData)
	{
		#if hl
		gl.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.buffer, 0, buffer.bufferBytesSize());
		#elseif (html5 && lime >= "5.0.0")
		gl.bufferSubDataWEBGL(GL.ARRAY_BUFFER, 0, buffer.buffer);
		#elseif (java || lime >= "4.0.0")
		gl.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.bufferBytesSize(), buffer.buffer);
		#else
		gl.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.buffer);
		#end
	}

	public static function build(vertexSource:String, fragmentSource:String):GLProgram
	{
		var vertexShader = compile(GL.VERTEX_SHADER, vertexSource);
		var fragmentShader = compile(GL.FRAGMENT_SHADER, fragmentSource);

		var glProgram = gl.createProgram();
		gl.attachShader(glProgram, fragmentShader);
		gl.attachShader(glProgram, vertexShader);
		gl.linkProgram(glProgram);
		#if hxpgl_debug
		if (gl.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
		#end

		return glProgram;
	}

	static function compile(type:Int, source:String):GLShader
	{
		var shader = gl.createShader(type);
		gl.shaderSource(shader, source);
		gl.compileShader(shader);
		#if hxpgl_debug
		if (gl.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader: " + gl.getShaderInfoLog(shader);
		#end
		return shader;
	}

	public static inline function clear()
	{
		var color = HXP.screen.color;
		gl.clearColor(color.red, color.green, color.blue, 1);
		gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	/**
	 * Rebuilds the renderbuffer to match screen dimensions
	 */
	public function resizeFramebuffer(fb:FrameBuffer)
	{
		gl.bindFramebuffer(GL.FRAMEBUFFER, fb.framebuffer);

		if (fb.texture != null) gl.deleteTexture(fb.texture);

		fb.width = HXP.screen.width;
		fb.height = HXP.screen.height;
		fb.texture = GLRenderer.createTexture(fb.width, fb.height);
		#if !java
		gl.bindFramebuffer(GL.FRAMEBUFFER, null);
		#end
	}

	public function bindFrameBuffer(fb:FrameBuffer)
	{
		if (GLUtils.invalid(fb.texture) || GLUtils.invalid(fb.framebuffer))
		{
			// detroy framebuffer
			if (fb.framebuffer != null) gl.deleteFramebuffer(fb.framebuffer);
			fb.texture = null;
			fb.width = fb.height = 0;

			// recreate
			fb.framebuffer = gl.createFramebuffer();
			resizeFramebuffer(fb);
		}
		else if (HXP.screen.width != fb.width || HXP.screen.height != fb.height)
		{
			resizeFramebuffer(fb);
		}

		gl.bindFramebuffer(GL.FRAMEBUFFER, fb.framebuffer);
		GLRenderer.clear();
	}

	public static function createTexture(width:Int, height:Int)
	{
		var texture = gl.createTexture();
		gl.bindTexture(GL.TEXTURE_2D, texture);
		#if (html5 && lime >= "5.0.0")
		gl.texImage2DWEBGL(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE);
		#else
		gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE,
			#if ((lime >= "4.0.0") && cpp) 0 #else null #end);
		#end

		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.LINEAR);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

		// specify texture as color attachment
		gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
		return texture;
	}

	static inline function setBlendMode(blend:BlendMode)
	{
		switch (blend)
		{
			case BlendMode.Add:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
			case BlendMode.Multiply:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFuncSeparate(GL.DST_COLOR, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE);
			case BlendMode.Screen:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFuncSeparate(GL.ONE, GL.ONE_MINUS_SRC_COLOR, GL.ZERO, GL.ONE);
			case BlendMode.Subtract:
				gl.blendEquationSeparate(GL.FUNC_REVERSE_SUBTRACT, GL.FUNC_ADD);
				gl.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
			case BlendMode.Alpha:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFunc(#if hl GL.SRC_ALPHA #else GL.ONE #end, GL.ONE_MINUS_SRC_ALPHA);
		}
	}

	static var _ortho:Float32Array;

	// for render to texture
	var fb:FrameBuffer;
	var backFb:FrameBuffer;

	var defaultFramebuffer:GLFramebuffer = null;

	var screenWidth:Int;
	var screenHeight:Int;
	var screenScaleX:Float;
	var screenScaleY:Float;

	public function new()
	{
		#if (ios && (lime && lime < 3))
		defaultFramebuffer = new GLFramebuffer(gl.version, gl.getParameter(gl.FRAMEBUFFER_BINDING));
		#end
		if (_ortho == null)
		{
			_ortho = new Float32Array(16);
			for (i in 0 ... 15)
			{
				_ortho[i] = 0;
			}
			_ortho[15] = 1;
		}
	}

	@:generic
	function getCompiledShader<T:CompiledShader>(shader:Shader, shaderClass:Class<T>):T
	{
		var compiled = _shaders.get(shader.id);
		if (compiled == null)
		{
			compiled = Type.createInstance(shaderClass, [shader]);
			_shaders.set(shader.id, compiled);
		}
		return cast compiled;
	}

	public function render(drawCommand:DrawCommand):Void
	{
		var x = this.x,
			y = this.y,
			width = this.width,
			height = this.height;

		if (drawCommand != null && !drawCommand.empty())
		{
			if (_tracking)
			{
				HXP.triangleCount += Std.int(drawCommand.indicies / 3);
				++HXP.drawCallCount;
				if (HXP.drawCallLimit > -1 && HXP.drawCallCount > HXP.drawCallLimit) return;
			}

			var clipRect = drawCommand.clipRect;
			if (clipRect != null)
			{
				width -= Std.int(clipRect.x);
				height -= Std.int(clipRect.y);
				width = Std.int(Math.min(width, clipRect.width));
				height = Std.int(Math.min(height, clipRect.height));
			}

			if (width > 0 && height > 0)
			{
				var shader = getCompiledShader(drawCommand.shader, CompiledShader);
				shader.bind();

				bindRenderbuffer(drawCommand.data);

				var matrixUniform = shader.uniformIndex(UNIFORM_MATRIX);
				if (matrixUniform != #if java -1 #else null #end) {
					#if hl
					gl.uniformMatrix4fv(matrixUniform, false, _ortho, 0, 1);
					#elseif (html5 && lime >= "5.0.0")
					gl.uniformMatrix4fvWEBGL(matrixUniform, false, _ortho);
					#elseif (java || lime >= "4.0.0")
					gl.uniformMatrix4fv(matrixUniform, 1, false, _ortho);
					#else
					gl.uniformMatrix4fv(matrixUniform, false, _ortho);
					#end
				}

				var texture:Texture = drawCommand.texture;
				if (texture != null) bindTexture(texture, drawCommand.smooth);

				shader.prepare(drawCommand);

				setBlendMode(drawCommand.blend);

				if (clipRect != null)
				{
					x += Std.int(Math.max(clipRect.x, 0));
					y += Std.int(Math.max(clipRect.y, 0));
				}

				gl.scissor(x, screenHeight - y - height, width, height);
				gl.enable(GL.SCISSOR_TEST);

				gl.drawArrays(GL.TRIANGLES, 0, drawCommand.indicies);

				gl.disable(GL.SCISSOR_TEST);

				// shader.unbind();
			}
		}
	}

	public static inline function createArrayBuffer():GLBuffer
	{
		return gl.createBuffer();
	}

	public static inline function bindArrayBuffer(buffer:GLBuffer)
	{
		gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
	}

	var byteSize:Int = 0;

	inline function bindRenderbuffer(data:BufferData)
	{
		#if !doc
		if (GLUtils.invalid(renderBuffer))
		{
			renderBuffer = createArrayBuffer();
		}
		bindArrayBuffer(renderBuffer);
		var size = data.bufferBytesSize();
		if (byteSize < size)
		{
			byteSize = size;
			bufferData(GL.ARRAY_BUFFER, byteSize, data.buffer, GL.DYNAMIC_DRAW);
		}
		#end
	}

	static function bindTexture(texture:Texture, smooth:Bool, ?index:Null<Int>)
	{
		if (index == null) index = GL.TEXTURE0;
		gl.activeTexture(index);
		texture.bind();
		if (smooth)
		{
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		}
		else
		{
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
	}

	public static inline function checkForErrors(?pos:PosInfos)
	{
		#if hxpgl_debug
		var error = gl.getError();
		if (error != GL.NO_ERROR)
			throw "GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error;
		#else
		var error = gl.getError();
		if (error != GL.NO_ERROR)
			Log.error("GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error);
		#end
	}

	public function startScene(scene:Scene)
	{
		_tracking = scene.trackDrawCalls;

		if (GLUtils.invalid(renderBuffer))
		{
			destroy();
			init();
		}

		var screen = HXP.screen;

		screenWidth = screen.width;
		screenHeight = screen.height;
		screenScaleX = screen.scaleX;
		screenScaleY = screen.scaleY;

		if (!startPostProcess(scene))
		{
			bindDefaultFramebuffer();
		}

		x = Std.int(screen.x + Math.max(scene.x, 0));
		y = Std.int(screen.y + Math.max(scene.y, 0));
		width = scene.width;
		height = scene.height;

		ortho(-x, screenWidth - x, screenHeight - y, -y);
		// needed for resizing viewport
		gl.viewport(0, 0, width, height);
	}

	@:access(haxepunk.Screen)
	function startPostProcess(scene:Scene):Bool
	{
		for (p in scene.shaders)
		{
			if (!p.active) continue;

trace("hi");
			// bind the first scene shader
			bindFrameBuffer(fb);
			var shader = getCompiledShader(p, CompiledSceneShader);
			if (shader.width != null || shader.height != null)
			{
				var w = shader.textureWidth,
					h = shader.textureHeight;
				var screen = HXP.screen;
				screen.scaleX *= w / screenWidth;
				screen.scaleY *= h / screenHeight;
				screen.width = w;
				screen.height = h;
			}
			return true;
		}
		return false;
	}

	function endPostProcess(scene:Scene)
	{
		var activeShaders:Array<CompiledSceneShader> = [];
		for (shader in scene.shaders)
		{
			if (shader.active)
			{
				activeShaders.push(getCompiledShader(shader, CompiledSceneShader));
			}
		}
		for (i in 0...activeShaders.length)
		{
			var last = i == activeShaders.length - 1;
			var shader = activeShaders[i];
			var renderTexture = fb.texture;

			var scaleX:Float, scaleY:Float;
			if (last)
			{
				// scale up to screen size
				scaleX = screenWidth / shader.textureWidth;
				scaleY = screenHeight / shader.textureHeight;
				bindDefaultFramebuffer();
			}
			else
			{
				// render to texture
				var next = activeShaders[i+1];
				scaleX = next.textureWidth / shader.textureWidth;
				scaleY = next.textureHeight / shader.textureHeight;
				var oldFb = fb;
				fb = backFb;
				backFb = oldFb;
				bindFrameBuffer(fb);
			}
			shader.setScale(scaleX, scaleY);
			shader.bind();

			gl.activeTexture(GL.TEXTURE0);
			gl.bindTexture(GL.TEXTURE_2D, renderTexture);

			#if desktop
			gl.enable(GL.TEXTURE_2D);
			#end

			if (shader.smooth)
			{
				gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
				gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			}
			else
			{
				gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
				gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			}

			setBlendMode(Alpha);
			gl.drawArrays(GL.TRIANGLES, 0, 6);
			// unbind();
		}
	}

	public function unbind()
	{
#if false
		gl.bindTexture(GL.TEXTURE_2D, null);

		#if desktop
		gl.disable(GL.TEXTURE_2D);
		#end

		shader.unbind();

		gl.bindFramebuffer(GL.FRAMEBUFFER, null);
#end
	}

	@:access(haxepunk.Screen)
	public function flushScene(scene:Scene)
	{
		var screen = HXP.screen;
		screen.width = screenWidth;
		screen.height = screenHeight;
		screen.scaleX = screenScaleX;
		screen.scaleY = screenScaleY;

		endPostProcess(scene);
	}

	public function startFrame()
	{
		HXP.triangleCount = 0;
		HXP.drawCallCount = 0;
		GLRenderer.clear();
	}
	public function endFrame() {}

	inline function init()
	{
		if (fb == null)
		{
			fb = {texture: null, framebuffer: null, width: 0, height: 0};
			backFb = {texture: null, framebuffer: null, width: 0, height: 0};
		}
	}

	inline function bindDefaultFramebuffer()
	{
		gl.bindFramebuffer(GL.FRAMEBUFFER, defaultFramebuffer);
	}

	inline function destroy() {}

	var x:Int = 0;
	var y:Int = 0;
	var width:Int = 0;
	var height:Int = 0;

	var renderBuffer:GLBuffer;
}

#end
