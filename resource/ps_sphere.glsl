#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform float value;

const float PI=3.14159265358979323846;

float speed=time*0.25;
float ground_x=0.5;//1.0+0.125*cos(PI*speed*0.25);
float ground_y=0.5;//1.0+0.125*sin(PI*speed*0.25);
float ground_z=speed;

vec2 rotate(vec2 k,float t)
	{
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float scene1(vec3 p)
	{
	float dot_p=0.1;
	float dot_w=dot_p*0.5;
	float dot=length(mod(p.xyz,dot_p)-dot_p*0.5)-dot_w;
	float ball_p=1.0;
	float ball_w=ball_p*(0.55+0.27*value);
	float ball=length(mod(p.xyz,ball_p)-ball_p*0.5)-ball_w;
	float hole_w=ball_p*(0.56+0.28*value);
	float hole=length(mod(p.xyz,ball_p)-ball_p*0.5)-hole_w;
	float hole2_p=0.1;
	float hole2_w=hole2_p*0.125;
	float hole2=length(mod(p.xyz,hole2_p)-hole2_p*0.5)-hole2_w;
	return max(max(dot,-mix(hole,hole2,0.5)),ball);
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
	vp.yz=rotate(vp.yz,PI*1.0*cos(speed*0.125));	// rotation x
	vp.zx=rotate(vp.zx,PI*1.0*sin(speed*0.125));	// rotation y
	vp.xy=rotate(vp.xy,speed*0.25);					// rotation z
	vec3 ray=vec3(ground_x,ground_y,ground_z);
	float t=0.0;
	const int ray_n=96;
	for(int i=0;i<ray_n;i++)
		{
		float d=scene1(ray+vp*t);
		t+=d*(1.0-value);
		}
	vec3 hit=ray+vp*t;
	vec2 h=vec2(-0.5,0.25); // light
	vec3 n=normalize(vec3(scene1(hit+h.xyy),scene1(hit+h.yxx),scene1(hit+h.yyx)));
	float c=(n.x+n.y+n.z)*0.2;
	vec3 color=vec3(c*0.25+t*0.0625,c*t*0.375,c*t*0.1+t*0.1);
	gl_FragColor=vec4(color+color*color*color,1.0);
	}