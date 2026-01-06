shader_type canvas_item;
render_mode blend_add;

uniform vec3 base_color : source_color;
uniform sampler2D noise;

vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat) {
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

vec4 boom(vec2 uv) {
	vec2 polar = polar_coordinates(uv, vec2(0.5), 1., 1.);
	float l = length(uv - vec2(0.5));

	float t = texture(noise, vec2(polar.y)).x;
	
	vec4 ret;
	
	ret.rgba = vec4(t - mix(0., 1.7, l));
	ret.rgb = mix(base_color * 2.5, vec3(-0.2), 1. - t);
	ret.a *= 5.;
	
	//if (distance(uv, vec2(.5)) < 0.05) {
		//return vec4(0.);
	//}
	
	return ret;
}

vec4 circle(vec2 uv) {
	float dist = distance(uv, vec2(.5));
	float value = 1. - distance(dist, .05);
	float ret = smoothstep(0.985, 1., value);
	return vec4(ret);
}

void fragment() {
	//COLOR = circle(UV) + boom(UV);
	COLOR = boom(UV);
}
