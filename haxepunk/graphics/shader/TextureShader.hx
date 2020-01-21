package haxepunk.graphics.shader;

import haxepunk.HXP;

class TextureShader extends Shader
{
#if (lime || nme || js)
	static var VERTEX_SHADER =
"#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec2 aTexCoord;
attribute vec4 aColor;
varying vec2 vTexCoord;
varying vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = vec4(aColor.bgr * aColor.a, aColor.a);
	vTexCoord = aTexCoord;
	gl_Position = uMatrix * aPosition;
}";

	static var FRAGMENT_SHADER =
"#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;
varying vec2 vTexCoord;
uniform sampler2D uImage0;

void main(void) {
	vec4 color = texture2D(uImage0, vTexCoord);
	if (color.a == 0.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor = color * vColor;
	}
}";
#else
	static var VERTEX_SHADER =
"#version 150

in vec4 aPosition;
in vec2 aTexCoord;
in vec4 aColor;
out vec2 vTexCoord;
out vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = vec4(aColor.bgr * aColor.a, aColor.a);
	vTexCoord = aTexCoord;
	gl_Position = uMatrix * aPosition;
}";

	static var FRAGMENT_SHADER =
"#version 150

in vec4 vColor;
in vec2 vTexCoord;
uniform sampler2D uImage0;
out vec4 fragColor;

void main(void) {
	vec4 color = texture(uImage0, vTexCoord);
	if (color.a == 0.0) {
		fragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		fragColor = color * vColor;
	}
}";
#end

	/**
	 * Create a custom shader from a text asset.
	 */
	public static inline function fromAsset(name:String):TextureShader
	{
		return new TextureShader(null, HXP.assetLoader.getText(name));
	}

	public function new(?vertex:String, ?fragment:String)
	{
		super(vertex == null ? VERTEX_SHADER : vertex, fragment == null ? FRAGMENT_SHADER : fragment);
		addAttribute("aPosition", Position);
		addAttribute("aTexCoord", TexCoord);
		addAttribute("aColor", VertexColor);
	}

	public static var defaultShader(get, null):Shader;
	static inline function get_defaultShader():Shader
	{
		if (defaultShader == null) defaultShader = new TextureShader();
		return defaultShader;
	}
}
