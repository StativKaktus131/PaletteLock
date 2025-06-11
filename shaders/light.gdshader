shader_type spatial;

uniform vec4 shadow_color : source_color;
uniform vec4 light_color : source_color;
uniform vec3 light_direction = vec3(-0.5, -1.0, -0.5); 
uniform float light_max;

const float dither_matrix[16] = float[16](
    0.0,  8.0,  2.0, 10.0,
   12.0,  4.0, 14.0,  6.0,
    3.0, 11.0,  1.0,  9.0,
   15.0,  7.0, 13.0,  5.0
);


float map(float var, float var_min, float var_max, float new_min, float new_max) {
	float per = (var - var_min) / (var_max - var_min);
	return new_min + per * (new_max - new_min);
}

void light() {
	float NDotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float light_intensity = NDotL * ATTENUATION;
	
	ivec2 screen_pos = ivec2(FRAGCOORD.xy) % 4;
	int idx = screen_pos.x + screen_pos.y * 4;
	float thresh = (dither_matrix[idx] + 0.5) / 16.0;
	
	float dithered = light_intensity > thresh ? 1.0 : 0.0;
	
	vec3 final = dithered * (light_color.rgb - shadow_color.rgb);
	
	DIFFUSE_LIGHT += final;
}

void fragment() {
	
}
