#ifdef GL_ES
	precision mediump float;
#endif

varying vec2 vTexCoord;
varying vec4 vColor;

uniform float uProgress;
uniform float uWidth;
uniform float uHeight;
uniform sampler2D uImage0;
uniform sampler2D uImage1;

void main(void)
{
    vec4 scene1 = texture2D(uImage0, vTexCoord);
    vec4 scene2 = texture2D(uImage1, vTexCoord);
	gl_FragColor = mix(scene1, scene2, uProgress);
}
