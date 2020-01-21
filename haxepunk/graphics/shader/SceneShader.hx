package haxepunk.graphics.shader;

import haxepunk.HXP;

/**
 * Used to create a custom shader.
 */
class SceneShader extends Shader
{
	static inline var DEFAULT_VERTEX_SHADER:String = "
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
	vTexCoord = aTexCoord;
	gl_Position = aPosition;
}";

	static inline var DEFAULT_FRAGMENT_SHADER:String = "
#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vTexCoord;
uniform sampler2D uImage0;
uniform vec2 uResolution;

void main () {
	gl_FragColor = texture2D(uImage0, vTexCoord);
}";

	/**
	 * Create a custom shader from a text asset.
	 */
	public static inline function fromAsset(name:String):SceneShader
	{
		return new SceneShader(HXP.assetLoader.getText(name));
	}

	public var active:Bool = true;
	public var smooth:Bool = false;

	/**
	 * Create a custom shader from a string.
	 */
	public function new(?fragment:String)
	{
		if (fragment == null)
		{
			fragment = DEFAULT_FRAGMENT_SHADER;
		}
		super(DEFAULT_VERTEX_SHADER, fragment);
		addAttribute("aPosition", Position);
		addAttribute("aTexCoord", TexCoord);
	}
}
