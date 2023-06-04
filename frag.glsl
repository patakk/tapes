precision mediump float;

varying vec2 v_uv;
uniform vec3 u_seed;
uniform vec2 u_resolution;
varying vec3 v_info;

float rand(vec2 co){
    float r1 = fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
    float r2 = fract(sin(dot(co.xy + .4132, vec2(12.9898,78.233))) * 43758.5453);
    float r3 = fract(sin(dot(co.xy + vec2(r1, r2),vec2(12.9898, 78.233))) * 43758.5453);
    return r1;
}

void main() {

    float rnd = rand(vec2(v_uv.x, v_uv.y));

    float var = v_uv.x;
    float vix = rand(vec2(v_info.x, v_info.x)/3.);

    float r = .52 + .48*sin(var*(.1 + 3.*mod(u_seed.x+vix, 1.)) + mod(u_seed.z+vix, 1.)*10. + vix*12.31);
    float g = .52 + .48*sin(var*(.1 + 3.*mod(u_seed.y+vix, 1.)) + mod(u_seed.x+vix, 1.)*10. + vix*12.31);
    float b = .52 + .48*sin(var*(.1 + 3.*mod(u_seed.z+vix, 1.)) + mod(u_seed.y+vix, 1.)*10. + vix*12.31);

    vec3 c1 = vec3(r, g, b);

    float var2 = v_uv.x + rnd*.02;
    float r2 = .52 + .48*sin(var2*(.1 + 3.*mod(u_seed.x+vix, 1.)) + mod(u_seed.z+vix, 1.)*10. + vix*12.31);
    float g2 = .52 + .48*sin(var2*(.1 + 3.*mod(u_seed.y+vix, 1.)) + mod(u_seed.x+vix, 1.)*10. + vix*12.31);
    float b2 = .52 + .48*sin(var2*(.1 + 3.*mod(u_seed.z+vix, 1.)) + mod(u_seed.y+vix, 1.)*10. + vix*12.31);
    vec3 c2 = vec3(r2, g2, b2);

    vec3 res = c1 + 0.0*(c2 - c1);


    gl_FragColor = vec4(res, 1.0);  // RGBA, purple color
}