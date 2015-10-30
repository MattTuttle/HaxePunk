package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Scene;
import haxepunk.math.Vector2;

enum TriangleFormat
{
	Strip;
	Fan;
}

class SpriteBatch
{

	/**
	 * The current material being used by SpriteBatch
	 */
	public static var material(get, set):Material;
	private static function get_material():Material
	{
		// always make sure we return a valid material
		if (_material == null)
		{
			_material = new Material();
			_material.firstPass;
		}
		return _material;
	}
	private static function set_material(value:Material):Material
	{
		if (value != _material)
		{
			flush();
			if (value != null)
			{
				var tex = value.firstPass.getTexture(0);
				if (tex != null)
				{
					_invTexWidth = 1 / tex.width;
					_invTexHeight = 1 / tex.height;
				}
			}
			_material = value;
		}
		return _material;
	}

	/**
	 * Adds a sprite to be drawn. Sprites are batched by material to reduce the number of draw calls.
	 * @param material the Material to be used (includes shader and texture passes)
	 * @param x the sprite's x-axis value
	 * @param y the sprite's y-axis value
	 * @param width the sprite's width
	 * @param height the sprite's height
	 * @param texX the sprite's uv rect x value (in pixels)
	 * @param texY the sprite's uv rect y value (in pixels)
	 * @param texWidth the sprite's uv rect width value (in pixels)
	 * @param texHeight the sprite's uv rect height value (in pixels)
	 * @param flipX flips sprite's uv coordinates on x-axis
	 * @param flipY flips sprite's uv coordinates on y-axis
	 * @param originX the sprite's x-axis anchor point for rotation
	 * @param originY the sprite's y-axis anchor point for rotation
	 * @param scaleX the sprite's x-axis scale value
	 * @param scaleY the sprite's y-axis scale value
	 * @param angle the sprite's rotation in radians
	 * @param tint the sprite's tint color
	 */
	public static function draw(material:Material, x:Float, y:Float, width:Float, height:Float,
		texX:Float, texY:Float, texWidth:Float, texHeight:Float, flipX:Bool=false, flipY:Bool=false,
		originX:Float=0, originY:Float=0, scaleX:Float=1, scaleY:Float=1, angle:Float=0, ?tint:Color):Void
	{
		SpriteBatch.material = material;

		var worldOriginX = x + originX;
		var worldOriginY = y + originY;

		var fx1 = -originX;
		var fy1 = -originY;
		var fx2 = width - originX;
		var fy2 = height - originY;

		if (scaleX != 1 || scaleY != 1)
		{
			fx1 *= scaleX;
			fy1 *= scaleY;
			fx2 *= scaleX;
			fy2 *= scaleY;
		}

		var x1 = fx1, y1 = fy1,
			x2 = fx1, y2 = fy2,
			x3 = fx2, y3 = fy2,
			x4 = fx2, y4 = fy1;

		if (angle != 0)
		{
			var cos = Math.cos(angle);
			var sin = Math.sin(angle);

			var tmp = x1;
			x1 = cos * tmp - sin * y1;
			y1 = sin * tmp + cos * y1;

			tmp = x2;
			x2 = cos * tmp - sin * y2;
			y2 = sin * tmp + cos * y2;

			tmp = x3;
			x3 = cos * tmp - sin * y3;
			y3 = sin * tmp + cos * y3;

			x4 = x1 + (x3 - x2);
			y4 = y3 - (y2 - y1);
		}

		x1 += worldOriginX; y1 += worldOriginY;
		x2 += worldOriginX; y2 += worldOriginY;
		x3 += worldOriginX; y3 += worldOriginY;
		x4 += worldOriginX; y4 += worldOriginY;

		var u1, u2;
		if (flipX)
		{
			u1 = (texX + texWidth) * _invTexWidth;
			u2 = texX * _invTexWidth;
		}
		else
		{
			u1 = texX * _invTexWidth;
			u2 = (texX + texWidth) * _invTexWidth;
		}

		var v1, v2;
		if (flipY)
		{
			v1 = (texY + texHeight) * _invTexHeight;
			v2 = texY * _invTexHeight;
		}
		else
		{
			v1 = texY * _invTexHeight;
			v2 = (texY + texHeight) * _invTexHeight;
		}

		var r, g, b, a;
		if (tint != null)
		{
			r = tint.r;
			g = tint.g;
			b = tint.b;
			a = tint.a;
		}
		else
		{
			r = g = b = a = 0;
		}

		addQuad();
		addVertex(x1, y1, u1, v1, r, g, b, a);
		addVertex(x2, y2, u1, v2, r, g, b, a);
		addVertex(x3, y3, u2, v2, r, g, b, a);
		addVertex(x4, y4, u2, v1, r, g, b, a);
	}

	/**
	 * Draw a triangle list.
	 * @param material The material to use for drawing.
	 * @param verts The triangle list vertices
	 * @param uvs The triangle list uvs
	 * @param format How to draw the triangle list, in a fan or strip.
	 * @param tint The color to tint the vertices.
	 */
	public static function drawTriangles(material:Material, verts:Array<Vector2>, uvs:Array<Vector2>, ?format:TriangleFormat, ?tint:Color):Void
	{
		var r, g, b, a;
		if (tint != null)
		{
			r = tint.r;
			g = tint.g;
			b = tint.b;
			a = tint.a;
		}
		else
		{
			r = g = b = a = 0;
		}

		SpriteBatch.material = material;

		// add indices
		var tris = verts.length - 2;
		if (_iIndex + tris * 3 > MAX_INDICES)
		{
			flush();
		}
		var index = _index;
		switch (format)
		{
			case Strip:
				for (i in 2...tris)
				{
					_triIndices[_iIndex++] = _index;
					_triIndices[_iIndex++] = _index+1;
					_triIndices[_iIndex++] = _index+2;
					_index += 1;
				}
				_index += 2;
			default:
				var first = _index++;
				for (i in 0...tris)
				{
					_triIndices[_iIndex++] = first;
					_triIndices[_iIndex++] = _index;
					_triIndices[_iIndex++] = _index+1;
					_index += 1;
				}
				_index += 1;
		}

		// add vertices
        for (i in 0...verts.length)
        {
			var vert = verts[i],
				uv = uvs[i];
			_triVertices[index++] = vert.x;
			_triVertices[index++] = vert.y;
			_triVertices[index++] = uv.x;
			_triVertices[index++] = uv.y;
			_triVertices[index++] = r;
			_triVertices[index++] = g;
			_triVertices[index++] = b;
			_triVertices[index++] = a;
        }
	}

	/** @private Increase the quad count and flush if over the limit */
	inline private static function addQuad()
	{
		if (_numQuads + 1 > MAX_QUADS)
		{
			flush();
		}
		_numQuads += 1; // must increment after in case a flush occurs
	}

	/** @private Adds a vertex to the quad list */
	inline private static function addVertex(x:Float=0, y:Float=0, u:Float=0, v:Float=0, r:Float=1, g:Float=1, b:Float=1, a:Float=1):Void
	{
		_quadVertices[_vIndex++] = x;
		_quadVertices[_vIndex++] = y;
		_quadVertices[_vIndex++] = u;
		_quadVertices[_vIndex++] = v;
		_quadVertices[_vIndex++] = r;
		_quadVertices[_vIndex++] = g;
		_quadVertices[_vIndex++] = b;
		_quadVertices[_vIndex++] = a;
	}

	/**
	 * Flushes the current SpriteBatch.
	 * This is automatically called on several conditions:
	 *   1. A batch limit is reached (either maximum quads or triangles)
	 *   2. The material has been changed
	 *   3. End of the scene's draw frame
	 */
	public static function flush():Void
	{
		var drawQuads = _numQuads > 0,
			drawTris = _iIndex > 0;
		if (!drawQuads && !drawTris) return;

		if (drawTris)
		{
			if (_triVertexBuffer == null)
			{
				_triVertexBuffer = Renderer.createBuffer(8);
			}
			Renderer.bindBuffer(_triVertexBuffer);
			Renderer.updateBuffer(_triVertices, STATIC_DRAW);
			_triIndexBuffer = Renderer.updateIndexBuffer(_triIndices, STATIC_DRAW, _triIndexBuffer);
		}

		if (drawQuads)
		{
			if (_quadVertexBuffer == null)
			{
				_quadVertexBuffer = Renderer.createBuffer(8);
				// create static quad index buffer
				var indices = new IntArray(#if !flash MAX_INDICES #end);
				var i = 0, j = 0;
				while (i < MAX_INDICES)
				{
					indices[i++] = j;
					indices[i++] = j+1;
					indices[i++] = j+2;

					indices[i++] = j;
					indices[i++] = j+2;
					indices[i++] = j+3;
					j += 4;
				}
				_quadIndexBuffer = Renderer.updateIndexBuffer(indices, STATIC_DRAW, _quadIndexBuffer);
			}

			Renderer.bindBuffer(_quadVertexBuffer);
			Renderer.updateBuffer(_quadVertices, STATIC_DRAW);
		}

		// grab the camera transform
		var cameraTransform = HXP.scene.camera.transform;

		// loop material passes
		for (pass in material.passes)
		{
			pass.use();
			Renderer.setMatrix(pass.shader.uniform("uMatrix"), cameraTransform);
			Renderer.setAttribute(pass.shader.attribute("aVertexPosition"), 0, 2);
			Renderer.setAttribute(pass.shader.attribute("aTexCoord"), 2, 2);
			Renderer.setAttribute(pass.shader.attribute("aColor"), 4, 4);

			if (drawTris)
			{
				Renderer.bindBuffer(_triVertexBuffer);
				Renderer.draw(_triIndexBuffer, Std.int(_iIndex / 3));
				Renderer.bindBuffer(_quadVertexBuffer);
			}

			if (drawQuads)
			{
				Renderer.draw(_quadIndexBuffer, _numQuads * 2);
			}
		}

		_numQuads = _vIndex = _iIndex = _index = 0;
	}

	private static var _index:Int = 0;
	private static var _iIndex:Int = 0;
	private static var _vIndex:Int = 0;
	private static var _numQuads:Int = 0;

	private static inline var MAX_VERTICES = 16384;
	private static inline var MAX_INDICES = 4092;
	private static inline var MAX_QUADS = 682; // MAX_INDICES / 6

	private static var _triIndices = new IntArray(#if !flash MAX_INDICES #end);
	private static var _triIndexBuffer:IndexBuffer;
	private static var _quadIndexBuffer:IndexBuffer;

	private static var _quadVertices = new FloatArray(#if !flash MAX_VERTICES #end);
	private static var _quadVertexBuffer:VertexBuffer;

	private static var _triVertices = new FloatArray(#if !flash MAX_VERTICES #end);
	private static var _triVertexBuffer:VertexBuffer;

	private static var _invTexWidth:Float = 0;
	private static var _invTexHeight:Float = 0;
	private static var _material:Material;

}
