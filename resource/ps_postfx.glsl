uniform sampler2D texture;
uniform int screen_w;
uniform int screen_h;
uniform float time;
uniform float flash;
uniform float value;
uniform float deform;
uniform bool scanline;
uniform float sync;

const float PI=3.14159265358979323846;
float lens=PI/(deform+sync*0.0625);

vec2 zoom(in vec2 p,in float radius)
	{
	float zoom=1.5-(radius*cos(p.x*PI/lens)+radius*cos(p.y*PI/lens));
	return vec2(p.x*zoom-0.5,p.y*zoom-0.5);
	}

vec3 get_color(in sampler2D tex,in vec2 p)
	{
	return (p.x<-1.0||p.x>0.0||p.y<-1.0||p.y>0.0)?vec3(0.0,0.0,0.0):texture2D(tex,p).xyz;
	}

float rand(in vec2 p)
	{
	return fract(sin(dot(p.xy,vec2(12.9898,78.233)))*43758.5453);
	}

void main(void)
	{
	vec2 q=gl_TexCoord[0].xy;
	vec2 p=-1.0+2.0*gl_TexCoord[0].xy;
	p.y+=0.025*sync;
	vec2 z =zoom(p,0.525);
	vec2 z1=zoom(p,0.528);
	vec2 z2=zoom(p,0.532);
	float g=(2.0-cos(PI/lens/2.0+z.x*PI/lens)-cos(PI/lens/2.0+z.y*PI/lens))*32.0;

	float rnd1=rand(vec2(p.x+time,p.y-time));
	float rnd2=rand(vec2(p.x-time,p.y+time));
	float d=rnd1*(4.0+sync*4.0)/float(screen_h);

	vec3 source=get_color(texture,z);
	vec3 glass1=get_color(texture,z1);
	vec3 glass2=get_color(texture,z2);

	float v=value*g;

	vec3 noise;
	noise.x=get_color(texture,vec2(z.x-v,z.y+d)).x;
	noise.y=get_color(texture,vec2(z.x  ,z.y-d)).y;
	noise.z=get_color(texture,vec2(z.x+v,z.y-d)).z;

	vec3 color=source+glass1*glass1+glass2*0.1+(scanline?noise:source);

	color+=flash;																// flash
	if(scanline)
		{
		color-=(vec3(rnd1,rnd1,rnd1)-vec3(rnd2,rnd2,rnd2))*0.125;				// noise
		color*=0.75+0.25*sin(z.x*float(screen_w*2));							// scanline w
		color*=0.90+0.10*cos(z.y*float(screen_h))*sin(0.5+z.x*float(screen_w));	// scanline h
		}
	else
		{
		color*=0.675;
		}
	color*=q.x*(6.0-q.x*6.0)*q.y*(6.0-q.y*6.0);									// vignetting
	gl_FragColor=vec4(color,1.0);
	}
