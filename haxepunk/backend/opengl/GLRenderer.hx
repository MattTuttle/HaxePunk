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
class GLRenderer implements Renderer
{
	public static var drawCallLimit:Int = -1;

	#if (!lime && js)
	public static var _GL:GL;
	#end

	public static inline var UNIFORM_MATRIX:String = "uMatrix";

	static var triangleCount:Int = 0;
	static var drawCallCount:Int = 0;
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
		_GL.bufferData(target, size, srcData, usage);
		#elseif (html5 && lime >= "5.0.0")
		_GL.bufferDataWEBGL(target, srcData, usage);
		#elseif (lime >= "4.0.0")
		_GL.bufferData(target, size, srcData, usage);
		#else
		_GL.bufferData(target, srcData, usage);
		#end
	}

	public static inline function bufferSubData(buffer:BufferData)
	{
		#if hl
		_GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.buffer, 0, buffer.bufferBytesSize());
		#elseif (html5 && lime >= "5.0.0")
		_GL.bufferSubDataWEBGL(GL.ARRAY_BUFFER, 0, buffer.buffer);
		#elseif (lime >= "4.0.0")
		_GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.bufferBytesSize(), buffer.buffer);
		#else
		_GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.buffer);
		#end
	}

	public static function build(vertexSource:String, fragmentSource:String):GLProgram
	{
		var vertexShader = compile(GL.VERTEX_SHADER, vertexSource);
		var fragmentShader = compile(GL.FRAGMENT_SHADER, fragmentSource);

		var glProgram = _GL.createProgram();
		_GL.attachShader(glProgram, fragmentShader);
		_GL.attachShader(glProgram, vertexShader);
		_GL.linkProgram(glProgram);
		#if hxp_gl_debug
		if (_GL.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
		#end

		return glProgram;
	}

	static function compile(type:Int, source:String):GLShader
	{
		var shader = _GL.createShader(type);
		_GL.shaderSource(shader, source);
		_GL.compileShader(shader);
		#if hxp_gl_debug
		if (_GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader: " + _GL.getShaderInfoLog(shader);
		#end
		return shader;
	}

	public static inline function clear(color:Color)
	{
		_GL.clearColor(color.red, color.green, color.blue, 1);
		_GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	/**
	 * Rebuilds the renderbuffer to match screen dimensions
	 */
	public function resizeFramebuffer(fb:FrameBuffer)
	{
		_GL.bindFramebuffer(GL.FRAMEBUFFER, fb.framebuffer);

		if (fb.texture != null) _GL.deleteTexture(fb.texture);

		fb.width = HXP.screen.width;
		fb.height = HXP.screen.height;
		fb.texture = GLRenderer.createTexture(fb.width, fb.height);
		_GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}

	public function bindFrameBuffer(fb:FrameBuffer)
	{
		if (GLUtils.invalid(fb.texture) || GLUtils.invalid(fb.framebuffer))
		{
			// detroy framebuffer
			_GL.deleteFramebuffer(fb.framebuffer);
			fb.texture = null;
			fb.width = fb.height = 0;

			// recreate
			fb.framebuffer = _GL.createFramebuffer();
			resizeFramebuffer(fb);
		}
		else if (HXP.screen.width != fb.width || HXP.screen.height != fb.height)
		{
			resizeFramebuffer(fb);
		}

		_GL.bindFramebuffer(GL.FRAMEBUFFER, fb.framebuffer);
		GLRenderer.clear(0);
	}

	public static function createTexture(width:Int, height:Int)
	{
		var texture = _GL.createTexture();
		_GL.bindTexture(GL.TEXTURE_2D, texture);
		#if (html5 && lime >= "5.0.0")
		_GL.texImage2DWEBGL(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE);
		#else
		_GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE,
			#if ((lime >= "4.0.0") && cpp) 0 #else null #end);
		#end

		_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.LINEAR);
		_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

		// specify texture as color attachment
		_GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
		return texture;
	}

	static inline function setBlendMode(blend:BlendMode)
	{
		switch (blend)
		{
			case BlendMode.Add:
				_GL.blendEquation(GL.FUNC_ADD);
				_GL.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
			case BlendMode.Multiply:
				_GL.blendEquation(GL.FUNC_ADD);
				_GL.blendFuncSeparate(GL.DST_COLOR, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE);
			case BlendMode.Screen:
				_GL.blendEquation(GL.FUNC_ADD);
				_GL.blendFuncSeparate(GL.ONE, GL.ONE_MINUS_SRC_COLOR, GL.ZERO, GL.ONE);
			case BlendMode.Subtract:
				_GL.blendEquationSeparate(GL.FUNC_REVERSE_SUBTRACT, GL.FUNC_ADD);
				_GL.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
			case BlendMode.Alpha:
				_GL.blendEquation(GL.FUNC_ADD);
				_GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
		}
	}

	static var _ortho:Float32Array;

	// for render to texture
	var fb:FrameBuffer;
	var backFb:FrameBuffer;

	var renderBufferData:BufferData;
	var defaultFramebuffer:GLFramebuffer = null;

	var screenWidth:Int;
	var screenHeight:Int;
	var screenScaleX:Float;
	var screenScaleY:Float;

	public function new()
	{
		#if (ios && (lime && lime < 3))
		defaultFramebuffer = new GLFramebuffer(_GL.version, _GL.getParameter(_GL.FRAMEBUFFER_BINDING));
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

	@:access(haxepunk.graphics.hardware.DrawCommand)
	public function render(drawCommand:DrawCommand):Void
	{
		checkForErrors();

		var x = this.x,
			y = this.y,
			width = this.width,
			height = this.height;

		if (drawCommand != null && drawCommand.triangleCount > 0)
		{
			if (_tracking)
			{
				triangleCount += drawCommand.triangleCount;
				++drawCallCount;
				if (drawCallLimit > -1 && drawCallCount > drawCallLimit) return;
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

				// expand arrays if necessary
				var triangles:Int = drawCommand.triangleCount;

				bindRenderbuffer(triangles, shader.floatsPerVertex * 3);

				var matrixUniform = shader.uniformIndex(UNIFORM_MATRIX);
				if (matrixUniform != null) {
					#if hl
					_GL.uniformMatrix4fv(matrixUniform, false, _ortho, 0, 1);
					#elseif (html5 && lime >= "5.0.0")
					_GL.uniformMatrix4fvWEBGL(matrixUniform, false, _ortho);
					#elseif (lime >= "4.0.0")
					_GL.uniformMatrix4fv(matrixUniform, 1, false, _ortho);
					#else
					_GL.uniformMatrix4fv(matrixUniform, false, _ortho);
					#end
				}

				checkForErrors();

				var texture:Texture = drawCommand.texture;
				if (texture != null) bindTexture(texture, drawCommand.smooth);
				checkForErrors();

				shader.prepare(drawCommand, renderBufferData);

				checkForErrors();

				setBlendMode(drawCommand.blend);

				if (clipRect != null)
				{
					x += Std.int(Math.max(clipRect.x, 0));
					y += Std.int(Math.max(clipRect.y, 0));
				}

				_GL.scissor(x, screenHeight - y - height, width, height);
				_GL.enable(GL.SCISSOR_TEST);

				_GL.drawArrays(GL.TRIANGLES, 0, triangles * 3);

				checkForErrors();

				_GL.disable(GL.SCISSOR_TEST);

				shader.unbind();

				checkForErrors();
			}
		}
	}

	public static inline function createArrayBuffer():GLBuffer
	{
		return _GL.createBuffer();
	}

	public static inline function bindArrayBuffer(buffer:GLBuffer)
	{
		_GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
	}

	inline function bindRenderbuffer(triangles:Int, floatsPerTriangle:Int)
	{
		#if !doc
		if (GLUtils.invalid(renderBuffer))
		{
			renderBufferData.buffer = null;
			renderBuffer = createArrayBuffer();
		}
		bindArrayBuffer(renderBuffer);
		if (renderBufferData.needsResize(triangles, floatsPerTriangle))
		{
			bufferData(GL.ARRAY_BUFFER, renderBufferData.bufferBytesSize(), renderBufferData.buffer, GL.DYNAMIC_DRAW);
		}
		#end
	}

	static function bindTexture(texture:Texture, smooth:Bool, index:Int=GL.TEXTURE0)
	{
		_GL.activeTexture(index);
		texture.bind();
		if (smooth)
		{
			_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		}
		else
		{
			_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}
		_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
	}

	public static inline function checkForErrors(?pos:PosInfos)
	{
		#if hxp_gl_debug
		var error = _GL.getError();
		if (error != GL.NO_ERROR)
			throw "GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error;
		#else
		var error = _GL.getError();
		if (error != GL.NO_ERROR)
			Log.error("GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error);
		#end
	}

	public function startScene(scene:Scene)
	{
		checkForErrors();
		_tracking = scene.trackDrawCalls;

		if (renderBufferData == null || GLUtils.invalid(renderBuffer))
		{
			destroy();
			init();
			checkForErrors();
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
	}

	@:access(haxepunk.Screen)
	function startPostProcess(scene:Scene):Bool
	{
		for (p in scene.shaders)
		{
			if (!p.active) continue;

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
				checkForErrors();
			}
			shader.setScale(scaleX, scaleY);
			shader.bind();
			checkForErrors();

			_GL.activeTexture(GL.TEXTURE0);
			_GL.bindTexture(GL.TEXTURE_2D, renderTexture);

			#if desktop
			_GL.enable(GL.TEXTURE_2D);
			#end

			if (shader.smooth)
			{
				_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
				_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			}
			else
			{
				_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
				_GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			}

			_GL.blendEquation(GL.FUNC_ADD);
			_GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
			_GL.drawArrays(GL.TRIANGLES, 0, 6);

			_GL.bindTexture(GL.TEXTURE_2D, null);

			#if desktop
			_GL.disable(GL.TEXTURE_2D);
			#end

			shader.unbind();

			_GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		}
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
		triangleCount = 0;
		drawCallCount = 0;
	}
	public function endFrame() {}

	inline function init()
	{
		if (renderBufferData == null)
		{
			renderBufferData = new BufferData();
		}
		if (fb == null)
		{
			fb = {texture: null, framebuffer: null, width: 0, height: 0};
			backFb = {texture: null, framebuffer: null, width: 0, height: 0};
		}
	}

	inline function bindDefaultFramebuffer()
	{
		_GL.bindFramebuffer(GL.FRAMEBUFFER, defaultFramebuffer);
	}

	inline function destroy() {}

	var x:Int = 0;
	var y:Int = 0;
	var width:Int = 0;
	var height:Int = 0;

	var renderBuffer:GLBuffer;
}

#end
