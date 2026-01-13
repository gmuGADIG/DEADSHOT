shader_type canvas_item;

uniform float t : hint_range(0., 1.);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);

	if (UV.y > -UV.x + t * 2.) {
		float luminosity = 0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b;
		COLOR.rgb = vec3(luminosity);
	}
}