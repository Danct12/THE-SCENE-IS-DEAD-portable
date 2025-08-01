#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform float value;

const float PI=3.14159265358979323846;

float speed=time*0.5;
float ground_x=6.0*sin(PI*speed*0.25);
float ground_y=1.25-1.25*value;
float ground_z=12.0*cos(PI*speed*0.125);

vec2 rotate(vec2 k,float t)
	{
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float cast_sky(vec3 p)
	{
	float ground=dot(p,vec3(0.0,1.0,0.0))+0.75;	// ground
	float mountain_y=4.0;
	float mountain_h=2.0;
	float mountain=mountain_y+mountain_h*sin(PI*p.x*0.25)+mountain_h*cos(PI*p.y*0.25)+mountain_h*sin(PI*p.z*0.25);
	mountain+=mountain_h*0.25*sin(PI*p.x*2.0-time*2.0)+mountain_h*0.25*cos(PI*p.y*2.0-time*4.0)+mountain_h*0.25*sin(PI*p.z*2.0);
	float pike_p=4.0;
	float pike_w=0.5*cos(PI*p.x*0.5)+0.5*sin(PI*p.y*0.5)+0.5*cos(PI*p.z*0.5);
	float pike=length(mod(p.xyz,pike_p)-pike_p*0.5)-pike_w;	// ground bubbles
	return max(ground+mountain,-mountain-pike);
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
	dir.yz=rotate(dir.yz,1.325);						// rotation x
	dir.zx=rotate(dir.zx,PI*0.5*sin(PI*speed*0.125)-value*0.0625);	// rotation y
	//dir.xy=rotate(dir.xy,0.5*cos(PI*speed*0.125));	// rotation z (let unactive)
	vec3 ray=vec3(ground_x,ground_y,ground_z-speed);
	float t=0.0;
	const int ray_n=64;
	for(int i=0;i<ray_n;i++)
		{
		float k=cast_sky(ray+dir*t);
		t+=k*0.25;
		}
	vec3 hit=ray+dir*t;
	vec2 h=vec2(0.25,-1.25); // light
	vec3 n=normalize(vec3(cast_sky(hit+h.xyx),cast_sky(hit+h.yxy),cast_sky(hit+h.yyx)));
	float c=(n.x*2.0+n.y+n.z)*0.125;
	vec3 color=vec3(c,c,c)-t*0.025;
	gl_FragColor=vec4(vec3(c+t*(0.0375-0.00625*sin(PI*p.y*0.5)),c+t*(0.025-0.0125*sin(PI*p.y*0.375)),c+t*0.0025)+color*color,1.0);
	}
