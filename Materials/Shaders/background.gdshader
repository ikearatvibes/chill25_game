shader_type canvas_item;

uniform float time_mult = 0.1;

//get pallete
vec3 palette(float t){
	vec3 a = vec3(0.588, 0.500, 0.500);
	vec3 b = vec3(-0.262, 0.188, -0.132); 
	vec3 c = vec3(1.158, 1.158, 1.000);
	vec3 d = vec3(-0.132, 0.333, 0.667);
    return a + b*cos( 6.283185*(c*t+d) );
}

void fragment() {
	vec2 uv_center = ((UV) - .5) * 2.0  * (SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.xy);
	
	vec3 col = palette(length(UV - vec2(10, 10)) + TIME * 0.025);
	
	COLOR = vec4(col, 1);
}