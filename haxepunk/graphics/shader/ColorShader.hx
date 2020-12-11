package haxepunk.graphics.shader;

@:dox(hide)
class ColorShader extends Shader
{
#if (lime || nme || js || android)
	static var VERTEX_SHADER =
"#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec4 aColor;
varying vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = vec4(aColor.bgr * aColor.a, aColor.a);
	gl_Position = uMatrix * aPosition;
}";

	static var FRAGMENT_SHADER =
"#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;

void main(void) {
	gl_FragColor = vColor;
}";
#else
	static var VERTEX_SHADER =
"#version 150

in vec4 aPosition;
in vec4 aColor;
out vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = vec4(aColor.bgr * aColor.a, aColor.a);
	gl_Position = uMatrix * aPosition;
}";

	static var FRAGMENT_SHADER =
"#version 150

in vec4 vColor;
out vec4 fragColor;

void main(void) {
	fragColor = vColor;
}";
#end

	public function new(?fragment:String)
	{
		super(VERTEX_SHADER, fragment == null ? FRAGMENT_SHADER : fragment);
		addAttribute("aPosition", Position);
		addAttribute("aColor", VertexColor);
	}

	public static var defaultShader(get, null):ColorShader;
	static inline function get_defaultShader():ColorShader
	{
		if (defaultShader == null) defaultShader = new ColorShader();
		return defaultShader;
	}
}
