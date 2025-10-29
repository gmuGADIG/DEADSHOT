shader_type spatial;
render_mode shadows_disabled, unshaded;

uniform float depth_start;
uniform float depth_range;
uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	float depth = textureLod(depth_texture, SCREEN_UV, 0).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0; // Only works on COMPATIBILITY renderer
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	float fog = clamp((-1.0 - world_position.y) / (depth_range), 0, 1);
	ALPHA = pow(fog, 1.5);
	ALBEDO = vec3(0);
	//ALBEDO = textureLod(screen_texture, SCREEN_UV, 0).rgb;
	
	//ALBEDO = vec3(-1.0 - world_position.y);
}
