uniform sampler2D texture;
uniform float screen_w;
uniform float screen_h;
uniform float time;
uniform float value;

float blur=value;

void main(void)
	{
	vec4 total=vec4(0.0);
	vec2 p=gl_TexCoord[0].xy/vec2(screen_w,screen_h);
	total+=texture2D(texture,vec2(p.x-blur*4.0,p.y))*0.04;
	total+=texture2D(texture,vec2(p.x-blur*3.0,p.y))*0.08;
	total+=texture2D(texture,vec2(p.x-blur*2.0,p.y))*0.12;
	total+=texture2D(texture,vec2(p.x-blur    ,p.y))*0.16;
	total+=texture2D(texture,vec2(p.x         ,p.y))*0.20;
	total+=texture2D(texture,vec2(p.x+blur    ,p.y))*0.16;
	total+=texture2D(texture,vec2(p.x+blur*2.0,p.y))*0.12;
	total+=texture2D(texture,vec2(p.x+blur*3.0,p.y))*0.08;
	total+=texture2D(texture,vec2(p.x+blur*4.0,p.y))*0.04;
	gl_FragColor=total;
	}
