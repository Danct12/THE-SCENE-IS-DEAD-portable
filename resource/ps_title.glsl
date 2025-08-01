#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform float value;

const float PI=3.14159265358979323846;

float speed=time*1.0;
float ground_x=0.0;//1.0+1.25*cos(PI*speed*0.125);
float ground_y=1.0+1.5*cos(PI*speed*0.0625);
float ground_z=speed-0.125*value;

vec2 rotate(vec2 k,float t)
	{
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float scene1(vec3 p)
	{
	float cube_p=2.0;
	float cube_w=cube_p*0.0625;
	float cube_x=length(max(abs(mod(p.yz,cube_p)-cube_p*0.5)-cube_w,0.0));
	float cube_y=length(max(abs(mod(p.xz,cube_p)-cube_p*0.5)-cube_w,0.0));
	float cube_z=length(max(abs(mod(p.xy,cube_p)-cube_p*0.5)-cube_w,0.0));
	float pipe_p=0.25;
	float pipe_w=pipe_p*0.325;
	float pipe_x=length(max(abs(mod(p.yz,pipe_p)-pipe_p*0.5)-pipe_w,0.0));
	float pipe_y=length(max(abs(mod(p.xz,pipe_p)-pipe_p*0.5)-pipe_w,0.0));
	float pipe_z=length(max(abs(mod(p.xy,pipe_p)-pipe_p*0.5)-pipe_w,0.0));
	float cut_p=2.0;
	float cut_w=cut_p*0.4125;
	float cut=length(mod(p.xyz,cut_p)-cut_p*0.5)-cut_w;
	float ball1_p=2.0;
	float ball1_w=ball1_p*0.175;
	float ball1=length(mod(p.xyz,ball1_p)-ball1_p*0.5)-ball1_w;
	float ball2_p=2.0;
	float ball2_w=ball2_p*0.1;
	float ball2=length(mod(p.xyz,ball2_p)-ball2_p*0.5)-ball2_w;
	float tube_p=2.0;
	float tube_w=tube_p*0.0125;
	float tube_x=length(max(abs(mod(p.yz,tube_p)-tube_p*0.5)-tube_w,0.0));
	float tube_y=length(max(abs(mod(p.xz,tube_p)-tube_p*0.5)-tube_w,0.0));
	float tube_z=length(max(abs(mod(p.xy,tube_p)-tube_p*0.5)-tube_w,0.0));
	return min(min(max(max(min(min(cube_x-pipe_x-pipe_y-pipe_z,cube_y-pipe_x-pipe_y-pipe_z),cube_z-pipe_x-pipe_y-pipe_z),cut),-ball1),ball2),min(min(tube_x,tube_y),tube_z));
	}

float scene2(vec3 p)
	{
	float laser_p=2.0;
	float laser_w=laser_p*0.00625;
	float laser_x=length(max(abs(mod(p.yz,laser_p)-laser_p*0.5)-laser_w,0.0));
	float laser_y=length(max(abs(mod(p.xz,laser_p)-laser_p*0.5)-laser_w,0.0));
	float laser_z=length(max(abs(mod(p.xy,laser_p)-laser_p*0.5)-laser_w,0.0));
	float light_p=2.0;
	float light_w=light_p*0.025;
	float light=length(mod(p.xyz,light_p)-light_p*0.5)-light_w;
	float glow_p=2.0;
	float glow_w=glow_p*0.1;
	float glow=length(mod(p.xyz,glow_p)-glow_p*0.5)-glow_w;
	return max(min(min(min(laser_x,laser_y),laser_z),glow),light);
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
	vp.yz=rotate(vp.yz,PI*0.5*sin(speed*0.125));	// rotation x
	vp.zx=rotate(vp.zx,PI*0.5*sin(speed*0.125));	// rotation y
	vp.xy=rotate(vp.xy,speed*0.25);					// rotation z
	vec3 ray=vec3(ground_x,ground_y,ground_z);
	float t=0.0;
	const int ray_n=64;
	for(int i=0;i<ray_n;i++)
		{
		float d=scene1(ray+vp*t)*scene2(ray+vp*t);
		if(d>0.25) d=0.25; // test
		t+=d*0.75;
		}
	vec3 hit=ray+vp*t;
	vec2 h=vec2(0.0025,-0.0025); // light
	vec3 n=normalize(vec3(scene1(hit+h.xyy),scene1(hit+h.yxx),scene1(hit+h.yyx)));
	float c=(n.x+n.y+n.z)*(0.25-0.025*value)+(0.2-t*0.15);
	gl_FragColor=vec4(vec3(c+t*0.025-0.0125*value,c+t*0.025,c+0.0625-t*0.0125+0.0125*value),1.0);
	}