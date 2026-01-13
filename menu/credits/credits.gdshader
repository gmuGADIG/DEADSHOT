shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise;

float unmix(float a, float b, float v)
{
    return (v - a) / (b - a);
}


void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	float n = textureLod(noise, SCREEN_UV, 0.).r;

	const float LINE = 0.075;
	float y = SCREEN_UV.y;
	float x = step(LINE, y + n * 0.075 - 0.05);
	
	COLOR.rgb = vec3(x);
	
	if (y < LINE + 0.08)
		COLOR.rgb = mix(
			COLOR.rgb, 
			mix(vec3(1., 0., 0.), vec3(1., 0.8, 0.), smoothstep(LINE, LINE + 0.04, y)), 
			1. - step(LINE, y + n * 0.02 - 0.05)
		);
	
	if (COLOR.rgb == vec3(1., 1., 1.)) COLOR.rgb *= c.rgb;
	
	COLOR.a = c.a * x;
}