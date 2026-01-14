shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise;
uniform sampler2D alpha_map;

uniform float alpha_threshold : hint_range(0.01, 0.1) = 0.075;
uniform float flame_threshold : hint_range(0.01, 0.1) = 0.02;
uniform float burn_end : hint_range(0.01, 0.2) = 0.1;
uniform float burn_start : hint_range(0.01, 0.2) = 0.05;
uniform float LINE : hint_range(0.01, 1.) = 0.075;

float unmix(float a, float b, float v)
{
    return (v - a) / (b - a);
}


void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	float n = textureLod(noise, SCREEN_UV, 0.).r;

	float y = SCREEN_UV.y;
	
	// alpha of our fire effect. 
	// all pixels above a certain line (below a certain Y threshold) will be cut off by fire.
	// this threshold is offset by the noise texture to create some interesting fire effects.
	float alpha = step(LINE, y + n * alpha_threshold - 0.05);
	
	
	// compute another mask. 
	// the black regions will sample a flame gradient.
	// the white regions will sample the screen texture (later)
	COLOR.rgb = mix(
		COLOR.rgb, 
		mix(vec3(1., 0., 0.), vec3(1., 0.8, 0.), smoothstep(LINE, LINE + 0.04, y)), 
		// this formula is similar to x, but the lower scalar on n causes the mask to ride lower
		// than `x`'s does.
		1. - step(LINE, y + n * flame_threshold - 0.05) 
	);
	
	if (COLOR.rgb == vec3(1., 1., 1.)) 
		COLOR.rgb *= c.rgb * 
			mix(vec3(0.15, 0.1, 0.1), vec3(1.), smoothstep(LINE + burn_start, LINE + burn_end, y));
	COLOR.a = c.a * alpha * 
		(1. - textureLod(alpha_map, SCREEN_UV, 0.).a); // haters will call this a "criminally insane solution"
													   // but the foreground texture has different colors than 
													   // the cutscene image for some reason
}