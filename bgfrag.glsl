precision mediump float;

uniform sampler2D u_texture;
uniform vec2 u_resolution;
uniform vec3 u_seed;

varying vec2 v_uv;

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
    sh.x = (rand(v_uv + 0.1)-.5) * 0.01 * .2;
    sh.y = (rand(v_uv + 0.2)-.5) * 0.01 * .1;
    sh *= .6;
    vec3 colorshifted = texture2D(u_texture, v_uv + sh).rgb;

    vec3 blurred1 = blur(v_uv, u_resolution, 1., .1);
    vec3 blurred2 = blur2(v_uv, u_resolution, 1., .1);

    vec3 result = color + (blurred1 - color)*.5;
    result = result + (colorshifted - result)*.0;

    result = blurred1 + .016*(-.5 + salt);
    result = clamp(result, 0., 1.);

    gl_FragColor = vec4(result.rgb, 1.);
}
