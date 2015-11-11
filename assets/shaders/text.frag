#ifdef GL_ES
	precision mediump float;
#endif

varying vec2 vTexCoord;
varying vec4 vColor;

uniform sampler2D uImage0;

void main(void)
{
	gl_FragColor = vec4(vColor.rgb, texture2D(uImage0, vTexCoord).a);
}
