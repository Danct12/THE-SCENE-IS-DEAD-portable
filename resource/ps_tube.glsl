#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform float value;

const float PI=3.14159265358979323846;

float speed=time*0.2975;
float ground_x=1.0;//-1.0*cos(PI*speed*1.0);
float ground_y=1.0;
float ground_z=1.0;

float v1=0.21;
float v2=0.20;

vec2 rotate(vec2 k,float t)
	{
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float cast_sky(vec3 p)
	{
	float tunnel_m=4.0+2.0*cos(PI*p.z*0.5);
	float tunnel_p=2.0;
	float tunnel_v=tunnel_p*0.025*cos(PI*p.y*4.0)+tunnel_p*0.0125*cos(PI*p.z*8.0);
	float tunnel1_w=tunnel_m*v1+tunnel_v;
	float tunnel1=length(mod(p.xy,tunnel_p)-tunnel_p*0.5)-tunnel1_w;
	float tunnel2_w=tunnel_m*v2+tunnel_v+tunnel_p*0.00125*sin(PI*p.x*32.0);
	float tunnel2=length(mod(p.xy,tunnel_p)-tunnel_p*0.5)-tunnel2_w;
	float hole_p=0.875;
	float hole_w=hole_p*0.35;
	float hole=length(mod(p.yz,hole_p).xy-hole_p*0.5)-hole_w;
	return min(min(min(-tunnel1,tunnel2),1.0),hole);
	}

void main(void)
	{
	#ifdef GL_ES
	vec2 position=(gl_FragCoord.xy/resolution.xy);
	#else
	vec2 position=(gl_TexCoord[0].xy/resolution.xy);
	#endif
	vec2 p=-1.0+2.0*position;
	vec3 dir=normalize(vec3(p*vec2(1.77,1.0),0.75));	// screen ratio (x,y) fov (z)
	//dir.yz=rotate(dir.yz,PI*0.0625);					// rotation x
	//dir.zx=rotate(dir.zx,-PI*speed*0.25);				// rotation y
	dir.xy=rotate(dir.xy,-PI-speed*0.5);				// rotation z
	vec3 ray=vec3(ground_x,ground_y,ground_z-speed*5.0);
	float t=0.0;
	const int ray_n=96;
	for(int i=0;i<ray_n;i++)
		{
		float k=cast_sky(ray+dir*t);
		t+=k*0.625;
		}
	vec3 hit=ray+dir*t;
	vec2 h=vec2(-0.0012,0.001); // light
	vec3 n=normalize(vec3(cast_sky(hit+h.xyx),cast_sky(hit+h.yxy),cast_sky(hit+h.yyx)));
	float c=(n.x+n.y+n.z)*0.325+t*0.0375;
	vec3 color=vec3(c,c,c);
	gl_FragColor=vec4(vec3(c-t*0.0125-p.x*t*0.0625,c-t*0.025-p.x*t*0.0125,c+t*0.025+p.x*t*0.0625)+color*color,1.0);
	}
