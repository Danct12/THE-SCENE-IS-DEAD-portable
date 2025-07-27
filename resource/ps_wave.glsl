uniform sampler2D texture;
uniform int screen_w;
uniform int screen_h;
uniform float time;
uniform float value;

const float PI=3.14159265358979323846;
const float PID=PI/180.0;

float r,g,b,a,y,sinus;

void main(void)
	{
	vec2 p=gl_TexCoord[0].xy;
	sinus=2.0-value;
	a=(p.y-value)*0.25*cos(1.0*cos(p.x*16.0+time)+p.y*(p.y*256.0)+time*2.0);
	y=1.0875-value-p.y+a;
	vec2 m=vec2(p.x,y);
	vec4 source=texture2D(texture,p);
	vec4 mirror=texture2D(texture,m);
	vec4 ground=vec4(0.1,0.25,0.25,1.0);
	vec4 color=(p.y>value)?source:((mirror.x==0.0&&mirror.y==0.0&&mirror.z==0.0)?ground:ground+mirror+mirror)*(-0.625+y*2.0+a*2.0);
	gl_FragColor=color;
	}
