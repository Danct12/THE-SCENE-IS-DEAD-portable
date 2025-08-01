uniform sampler2D texture;
uniform int screen_w;
uniform int screen_h;
uniform float time;
uniform float value1;
uniform float value2;
uniform float color;

float PI=3.14159265358979323846;

vec3 deform(in vec2 p)
	{
	vec2 uv;
	float zoom=0.5;
	uv.x=p.x*zoom-0.5;
	uv.y=p.y*zoom-0.5;
	return texture2D(texture,uv).xyz;
	}

void main(void)
	{
	int n=32;

	vec2 p=-1.0+4.0*gl_TexCoord[0].xy;
	vec2 s=p;
	vec3 source=deform(s);

	vec3 total=vec3(0,1.0,1.0);

	vec2 d=-p/float(n*2);
	float w=value1;
	for(int i=0;i<n;i++)
		{
		vec3 c=deform(s);
		vec3 data=c+vec3(c.x*color-p.x*color,c.z*color+p.y*color,c.y*color+p.x*color);
		total+=data*w;
		w*=value2;
		s+=d;
		}
	gl_FragColor=vec4(source*0.625+total*0.025,1.0);
	}
