uniform sampler2D texture;
uniform sampler2D texture_prv;
uniform int screen_w;
uniform int screen_h;
uniform float time;
uniform float step;
uniform float value1;
uniform float value2;

void main(void)
	{
	vec2 p=gl_TexCoord[0].xy;
	vec4 source=texture2D(texture_prv,p);
	vec4 glow=texture2D(texture,p);
	source=smoothstep(step,1.0,source);
	vec4 color=glow*value1+source*value2;
	gl_FragColor=color;
	}
