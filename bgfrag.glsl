precision mediump float;

uniform sampler2D u_texture;
uniform vec2 u_resolution;
uniform vec3 u_seed;

varying vec2 v_uv;


#define NUM_OCTAVES 8


float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
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


vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
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

vec3 blur(vec2 uv, vec2 resolution, float radius, float intensity) {
    vec3 color = vec3(0.);
    vec2 step = 3. / resolution;
    for(float x = -1.0; x <= 1.0; x += 1.) {
        for(float y = -1.0; y <= 1.0; y += 1.) {
            color += texture2D(u_texture, uv + vec2(x, y) / resolution).rgb;
        }
    }
    return color/9.;
}


vec3 blur2(vec2 uv, vec2 resolution, float radius, float intensity) {
    vec3 color = vec3(0.);
    vec2 step = 3. / resolution;
    for(float x = -10.0; x <= 10.0; x += 2.) {
        for(float y = -10.0; y <= 10.0; y += 2.) {
            color += texture2D(u_texture, uv + vec2(x, y) / resolution).rgb;
        }
    }
    return color/121.;
}

void main() {
    vec3 color = texture2D(u_texture, v_uv).rgb;

    float salt = rand(v_uv + 0.3 + u_seed.x);

    vec2 sh = vec2(0.);
    sh.x = (fbm3(v_uv*113. + 0.1, 1.213)-.5);
    sh.y = (fbm3(v_uv*113. + 0.2, 4.213)-.5);
    sh *= .0013 * vec2(1., 1.);

    float nnz = smoothstep(.2, .5, pow(fbm3(v_uv*77. + 0.1, 4.55+u_seed.z), 3.));
    sh *= 1. + nnz*1.;
    vec3 colorshifted = texture2D(u_texture, v_uv + sh).rgb;

    vec3 blurred1 = blur(v_uv, u_resolution, 1., .1);
    vec3 blurred2 = blur2(v_uv, u_resolution, 1., .1);

    vec3 result = blurred1;
    result = result + (vec3(1.) - result)*.0;

    vec2 abspos = v_uv * u_resolution;
    float marg = u_resolution.x * .02;
    if(abspos.x < marg || abspos.x > u_resolution.x - marg || abspos.y < marg || abspos.y > u_resolution.y - marg){
        result = vec3(.15);
    }

    result = result + .126*(-.5 + salt);
    result = clamp(result, 0., 1.);

    gl_FragColor = vec4(vec3(nnz), 1.);
    gl_FragColor = vec4(result.rgb, 1.);
}
