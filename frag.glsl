precision mediump float;

varying vec2 v_uv;
uniform vec3 u_seed;
uniform float u_version;
uniform vec2 u_resolution;
varying vec3 v_info;

uniform sampler2D u_randomTexture;
uniform vec2 u_randomTextureSize;

#define NUM_OCTAVES 8

vec4 hcrandom(vec3 co) {
    // Map the coordinates to the range [0, 1] so we can use them to sample the texture.
    vec2 uv = fract(co.xy+co.z*1.13141);

    // Sample the texture and return a random value in the range [0, 1].
    return texture2D(u_randomTexture, uv).rgba;
}


// float hash12(vec2 p)
// {
// 	vec3 p3  = fract(vec3(p.xyx) * .1031);
//     p3 += dot(p3, p3.yzx + 33.33);
//     return fract((p3.x + p3.y) * p3.z);
// }


float hash12(vec2 p)
{
	return hcrandom(vec3(p, 0.)*1013.31).r;
}

float noise (vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners2D of a tile
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float noise3 (vec2 _st,float t) {
    vec2 i = floor(_st+t);
    vec2 f = fract(_st+t);

    // Four corners2D of a tile
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm (vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}


// vec3 random3(vec3 c) {
// 	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
// 	vec3 r;
// 	r.z = fract(512.0*j);
// 	j *= .125;
// 	r.x = fract(512.0*j);
// 	j *= .125;
// 	r.y = fract(512.0*j);
// 	return r-0.5;
// }

vec3 random3(vec3 c) {
	return hcrandom(c).rgb;
}
/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float simplex3d(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	 
	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));
	 
	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;
	 
	 /* 2. find four surflets and store themd */
	 vec4 w, d;
	 
	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);
	 
	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);
	 
	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 /* 3. return the sum of the four surflets */
	 return .5+.5*dot(d, vec4(52.0));
}

float power(float p, float g) {
    if (p < 0.5)
        return 0.5 * pow(2.*p, g);
    else
        return 1. - 0.5 * pow(2.*(1. - p), g);
}
float fbm3 (vec2 _st, float t) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise3(_st, t);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float rand(vec2 co){
    float r1 = fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
    float r2 = fract(sin(dot(co.xy + .4132, vec2(12.9898,78.233))) * 43758.5453);
    float r3 = fract(sin(dot(co.xy + vec2(r1, r2),vec2(12.9898, 78.233))) * 43758.5453);
    return r1;
}

void main() {

    float rnd = rand(vec2(v_uv.x, v_uv.y));

    float var = v_uv.x * .00051;
    var = v_uv.x;

    float vix = rand(vec2(v_info.x, v_info.x)/3.)*0.;

    float r = .52 + .48*sin(var*(.1 + 3.*mod(u_seed.x+vix, 1.)) + mod(u_seed.z+vix, 1.)*10. + vix*12.31);
    float g = .52 + .48*sin(var*(.1 + 3.*mod(u_seed.y+vix, 1.)) + mod(u_seed.x+vix, 1.)*10. + vix*12.31);
    float b = .52 + .48*sin(var*(.1 + 3.*mod(u_seed.z+vix, 1.)) + mod(u_seed.y+vix, 1.)*10. + vix*12.31);
    
    float xx;

    xx = var;
    r = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.x*100.+vix*20.))), 3.);
    g = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.y*100.+vix*20.))), 3.);
    b = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.z*100.+vix*20.))), 3.);

    vec3 c0 = vec3(r, g, b);

    xx = var + hash12(v_uv.xx*4.4+hash12(v_uv.xx*4.4)) * 0.07;
    r = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.x*100.+vix*20.))), 3.);
    g = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.y*100.+vix*20.))), 3.);
    b = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.z*100.+vix*20.))), 3.);

    vec3 c1 = vec3(r, g, b);
    
    float strk = 277.22 + .0*power(clamp(simplex3d(vec3(v_uv.x*0.00004+11.44, v_uv.x*0.00004, u_seed.x+vix*20.+22.3)), 0., 1.), 5.);

    xx = var + hash12(v_uv.xx) * 0.0;
    xx += .019*(-.5 + hash12(vec2(floor(v_uv.x*strk)/1.)));
    r = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.x*100.+vix*20.))), 3.);
    g = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.y*100.+vix*20.))), 3.);
    b = 0.0+0.999*power(smoothstep(.2, .8, simplex3d(vec3(xx, xx, u_seed.z*100.+vix*20.))), 3.);

    vec3 c2 = vec3(r, g, b);

    float nz = power(clamp(simplex3d(vec3(v_uv.x*0.94*2., v_uv.y*0.94, u_seed.x+vix*20.)), 0., 1.), 5.);
    float nz2 = .2*power(clamp(simplex3d(vec3(v_uv.x*0.34*2.+29., v_uv.y*2.94, u_seed.x+vix*20.+131.31)), 0., 1.), 5.);
    vec3 res = c0;
    res = res + (c2-res)*nz2;

    vec3 randomcolor = vec3(
        .3 + .7*hash12(vec2(v_info.x*0.+u_seed.x)),
        .3 + .7*hash12(vec2(v_info.x*0.+u_seed.x+23.21)),
        .3 + .7*hash12(vec2(v_info.x*0.+u_seed.x+31.1))
    );

    res = res + (1.-res)*.2;

    float gr = pow(hash12(vec2(floor(v_uv.x*1.)/1.)), 9.);
    gr = clamp(smoothstep(.3, .5, gr), 0., 1.)*.2;
    // vec3 red = vec3(gr, 0., 0.);

    vec3 red = vec3(.8, .2, 0.);
    vec3 orange = vec3(.8, .4, 0.);
    vec3 yellow = vec3(.8, .8, 0.);
    vec3 green = vec3(.2, .8, 0.);
    vec3 blue = vec3(.2, .4, .8);
    vec3 purple = vec3(.8, .2, .8);
    vec3 white = vec3(.8, .8, .8);
    vec3 drakblue = vec3(.0, .0, .4);

    float redamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.x*100.+vix*20. + 551.55)), 0., 1.), 3.);
    float orangeamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.x*100.+vix*20. + 12.34)), 0., 1.), 3.);
    float yellowamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.y*100.+vix*20. + 23.6)), 0., 1.), 3.);
    float greenamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.z*100.+vix*20. + 445.43)), 0., 1.), 3.);
    float blueamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.x*100.+vix*20. + 34.21)), 0., 1.), 3.);
    float purpleamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.y*100.+vix*20. + 62.5)), 0., 1.), 3.);
    float whiteamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.z*100.+vix*20. + 788.23)), 0., 1.), 3.);
    float drakblueamp = power(clamp(simplex3d(vec3(xx, xx, u_seed.x*100.+vix*20. + 55.12)), 0., 1.), 3.);

    vec3 res2 = red*redamp + orange*orangeamp + drakblue*drakblueamp + yellow*yellowamp + green*greenamp + blue*blueamp + purple*purpleamp + white*whiteamp;

    res2 = clamp(res2/3.5, 0., 1.);

    gl_FragColor = vec4(0.0,0.0,0.0, 1.0);  // RGBA, purple color
    gl_FragColor = vec4(res, 1.0);  // RGBA, purple color
    if(u_seed.z < 0.001 && abs(u_version-1.0) < 0.001){
        float hhhs = hash12(vec2(v_uv.x*2.4, v_uv.y*2.4));
        gl_FragColor = vec4(hhhs*.9+.1, hhhs*.9+.1, hhhs*.9+.1, 1.0);  // RGBA, purple color
    }
    if(u_seed.z < 0.001 && abs(u_version-2.0) < 0.001){
        float uvx = v_uv.x + .1*fbm3(v_uv.xy*3., v_info.x*0.1);
        float oo = hash12(vec2(v_info.x*0.4, v_info.y*0.4))*0.;
        float ix = floor(uvx*(111.+177.*oo));
        float rr = .05+.9*mod(ix, 2.);
        gl_FragColor = vec4(vec3(rr, rr, rr), 1.0);  // RGBA, purple color
    }
    if(u_seed.z < 0.001 && abs(u_version-3.0) < 0.001){
        float rnd = rand(vec2(v_uv.x, v_uv.y));
        float var = v_uv.x;
        float oo = hash12(vec2(v_info.x*0.4, v_info.y*0.4)) * 0. + 1.;
        float ix = floor(v_uv.x*(111.+77.*oo));
        float iy = floor(v_uv.y*(111.+77.*oo));
        float rr = .15 + .8*(mod(ix, 2.) * (mod(iy, 2.)));
        gl_FragColor = vec4(vec3(rr, rr, rr), 1.0);  // RGBA, purple color
    }
    if(abs(u_version-4.0) < 0.001){
        float uvx = v_uv.x + .1*fbm3(v_uv.xy*3., v_info.x*0.1);
        float oo = hash12(vec2(v_info.x*0.4, v_info.y*0.4))*0.;
        float ix = floor(uvx*(111.+177.*oo));
        float rr = .2+.7*mod(ix, 2.);
        gl_FragColor = vec4(vec3(rr, rr, rr), 1.0);  // RGBA, purple color
    }
    if(abs(u_version-5.0) < 0.001){
        float rnd = rand(vec2(v_uv.x, v_uv.y));
        float var = v_uv.x;
        float oo = hash12(vec2(v_info.x*0.4, v_info.y*0.4)) * 0. + 1.;
        float ix = floor(v_uv.x*(111.+77.*oo));
        float iy = floor(v_uv.y*(111.+77.*oo));
        float rr = .15 + .8*(mod(ix, 2.) * (mod(iy, 2.)));
        gl_FragColor = vec4(vec3(rr, rr, rr), 1.0);  // RGBA, purple color
    }
    // gl_FragColor = vec4(randomcolor, 1.0);  // RGBA, purple color
     //gl_FragColor = vec4(vec3(nz2), 1.0);  // RGBA, purple color

    // gl_FragColor = vec4(v_uv.x, v_uv.y, 0., 1.0);  // RGBA, purple color
    // float randValue = clamp(hcrandom(v_uv.xyx).r, 0., 1.);
    // gl_FragColor = vec4(vec3(randValue), 1.0);  // RGBA, purple color
}

void main2() {

    float rnd = rand(vec2(v_uv.x, v_uv.y));

    float var = v_uv.x;

    float oo = hash12(vec2(v_info.x*0.4, v_info.y*0.4)) * 0. + 1.;
    float ix = floor(v_uv.x*(111.+77.*oo));
    float iy = floor(v_uv.y*(111.+77.*oo));

    float rr = (mod(ix, 2.) * (mod(iy, 2.)));

    gl_FragColor = vec4(vec3(rr, rr, rr), 1.0);  // RGBA, purple color
    if(u_seed.z < 0.001){
        float hhhs = hash12(vec2(v_uv.x*444.4, v_uv.y*444.4));
        gl_FragColor = vec4(hhhs*.9+.1, hhhs*.9+.1, hhhs*.9+.1, 1.0);  // RGBA, purple color
    }

}