#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform float value1;
uniform float value2;

const float PI=3.14159265358979323846;

float speed=time*1.0;
float ground_x=0.0;//1.0*cos(PI*speed*0.125);
float ground_y=2.0;
float ground_z=speed;

vec2 rotate(vec2 k,float t)
	{
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float scene(vec3 p)
	{
	float mountain_h=1.0+0.25*cos(PI*p.x*0.5+PI*p.z*0.0625)+0.125*sin(PI*p.z*0.5-PI*p.x*1.0);
	mountain_h+=0.0375*cos(PI*p.x*4.0)+0.025*sin(PI*p.z*2.0);
	float mountain_w=0.5;
	float mountain=length(p.y+mountain_h)-mountain_w;
	float tower_p=4.0;
	float tower_w=tower_p*0.0625;
	float tower=length(max(abs(mod(p.xz,tower_p)-tower_p*0.5-tower_p*0.075*p.xy)-tower_w,0.0));
	float cube_p=1.0;
	float cube_w=cube_p*0.75*sin(PI*p.y*0.25);
	float cube=length(max(abs(mod(p.xyz,cube_p)-cube_p*0.5)-cube_w,0.0));
	float value=min(mountain,mix(tower,-cube,0.375-0.125*p.y));
	return value*(0.625+0.625*sin(PI*p.x*0.0625+PI*0.5));
	}

void main(void)
	{
	#ifdef GL_ES
	vec2 position=(gl_FragCoord.xy/resolution.xy);
	#else
	vec2 position=(gl_TexCoord[0].xy/resolution.xy);
	#endif
	vec2 p=-1.0+2.0*position;
	vec3 vp=normalize(vec3(p*vec2(1.77,1.0),0.75)); // screen ratio (x,y) fov (z)
	//vp.yz=rotate(vp.yz,-0.25);		// rotation x
	//vp.zx=rotate(vp.zx,speed*0.0625);	// rotation y
	//vp.xy=rotate(vp.xy,PI*0.5);		// rotation z
	vec3 ray=vec3(ground_x,ground_y,ground_z);
	float t=0.0;
	const int ray_n=64;//+16;
	for(int i=0;i<ray_n;i++)
		{
		float d=scene(ray+vp*t);
		t+=d*(0.625-0.625*value1-0.625*value2);
		}
	vec3 hit=ray+vp*t;
	vec2 h=vec2(-0.0025,0.0025); // light
	vec3 n=normalize(vec3(scene(hit+h.xyy),scene(hit+h.yxx),scene(hit+h.yyx)));
	float c=(n.x+n.y+n.z)*0.125;
	gl_FragColor=vec4(vec3(c+t*0.00125+p.y*0.025,c+t*0.000375-p.y*0.05,c-t*0.00025+p.y*0.025)*(1.0-value1)*(1.0-value2),1.0);
	}