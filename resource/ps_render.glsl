#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform float value;

const float PI=3.14159265358979323846;

float speed=time*0.5;
float ground_x=1.5*cos(PI*speed*0.125);
float ground_y=4.0-3.0*sin(PI*speed*0.125)+0.125*value;
float ground_z=-1.0-speed;

vec2 rotate(vec2 k,float t)
	{
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float scene1(vec3 p)
	{
	float ground=dot(p,vec3(0.0,1.0,0.0))+0.75;
	float t1=length(abs(mod(p.xyz,2.0)-1.0))-1.35+0.05*cos(PI*p.x*4.0)+0.05*sin(PI*p.z*4.0);	// structure
	float t3=length(max(abs(mod(p.xyz,2.0)-1.0).xz-1.0,0.5))-0.075+0.1*cos(p.y*36.0);			// structure slices
	float t5=length(abs(mod(p.xyz,0.5))-0.25)-0.975;
	float bubble_p=0.1;
	float bubble_w=0.75+0.25*cos(PI*p.z*1.0)+0.25*cos(PI*p.x*1.0);
	float bubble=length(mod(p.xyz,bubble_p)-bubble_p*0.5)-bubble_w;
	float hole_p=1.0;
	float hole_w=hole_p*0.05;
	float hole=length(abs(mod(p.xz,hole_p)-hole_p*0.5))-hole_w;
	float tube_p=2.0-0.25*sin(PI*p.z*0.5);
	float tube_v=PI*6.0;
	float tube_w=tube_p*0.025+tube_p*0.05*cos(p.x*tube_v)*sin(p.y*tube_v)*cos(p.z*tube_v)+tube_p*0.025*sin(PI*p.z*0.5+speed*4.0);
	float tube=length(abs(mod(p.xy,tube_p)-tube_p*0.5))-tube_w;
	return min(max(min(-t1,max(-hole-t5*0.375,ground+bubble)),t3+t5),tube);
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
	dir.yz=rotate(dir.yz,PI*0.25*sin(PI*speed*0.125)-value*0.25);	// rotation x
	dir.zx=rotate(dir.zx,PI*cos(-PI*speed*0.05));		// rotation y
	dir.xy=rotate(dir.xy,PI*0.125*cos(PI*speed*0.125));	// rotation z
	vec3 ray=vec3(ground_x,ground_y,ground_z);
	float t=0.0;
	const int ray_n=64;
	for(int i=0;i<ray_n;i++)
		{
		float k=scene1(ray+dir*t);
		t+=k*0.625;
		}
	vec3 hit=ray+dir*t;
	vec2 h=vec2(-0.025,0.0125); // light
	vec3 n=normalize(vec3(scene1(hit+h.xyy),scene1(hit+h.yxx),scene1(hit+h.yyx)));
	float c=(n.x+n.y+n.z)*0.25;
	vec3 color=vec3(c,c,c)-t*0.05;
	gl_FragColor=vec4(vec3(c*0.25+t*0.05,c*0.375+t*0.025,c*0.5+t*0.00625)+color*color,1.0);
	}