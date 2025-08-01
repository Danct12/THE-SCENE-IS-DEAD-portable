#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform int type;
uniform float value;
uniform float sync;

const float PI=3.14159265358979323846;

float speed=time*0.25;
float ground_x=0.125-0.25*cos(PI*speed*0.25);
float ground_y=0.125+0.25*sin(PI*speed*0.25);
float ground_z=speed*0.125;

vec2 rotate(vec2 k,float t)
	{
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float scene1(vec3 p)
	{
	float ball_p=0.25;
	float ball_w=ball_p*1.0;
	float ball=length(mod(p.xyz,ball_p)-ball_p*0.5)-ball_w;
	float hole_w=ball_p*0.5675;
	float hole=length(mod(p.xyz,ball_p)-ball_p*0.5)-hole_w;
	float pipe_p=0.0625;
	float pipe_w=pipe_p*0.275;//-0.00375*sync;
	float pipe_x=length(max(abs(mod(p.yz,pipe_p)-pipe_p*0.5)-pipe_w,0.0));
	float pipe_y=length(max(abs(mod(p.xz,pipe_p)-pipe_p*0.5)-pipe_w,0.0));
	float pipe_z=length(max(abs(mod(p.xy,pipe_p)-pipe_p*0.5)-pipe_w,0.0));
	return max(max(ball,-hole),max(pipe_x,max(pipe_y,pipe_z)));
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
	vp.yz=rotate(vp.yz,PI*1.0*sin(speed*0.25));		// rotation x
	vp.zx=rotate(vp.zx,PI*1.0*cos(speed*0.25));		// rotation y
	vp.xy=rotate(vp.xy,-speed*0.5);					// rotation z
	vec3 ray=vec3(ground_x,ground_y,ground_z);
	float t=0.0;
	const int ray_n=96;
	for(int i=0;i<ray_n;i++)
		{
		float d=scene1(ray+vp*t);
		t+=d;//*0.875;
		}
	vec3 hit=ray+vp*t;
	vec2 h=vec2(-0.00025,0.00025); // light
	vec3 n=normalize(vec3(scene1(hit+h.xyy),scene1(hit+h.yxx),scene1(hit+h.yyx)));
	float c=(n.x+n.y+n.z)*0.2;
	vec3 color=(type==0)?vec3(c*t*0.375+p.x*0.125,c*t*0.125+t*0.1,c*t*0.125+t*0.125+p.x*0.0625):vec3(c*0.025+t*0.2,c*t*0.125+t*0.125,c*t*0.125+t*0.0625);
	gl_FragColor=vec4(smoothstep(0.1,0.8,color)+color+color*color,1.0);
	}