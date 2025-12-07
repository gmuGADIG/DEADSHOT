shader_type canvas_item;

uniform sampler2D blood;
uniform float radius: hint_range(0.0, 1.2);

void fragment() {
	vec2 uv = UV - vec2(.5);
	uv.y *= 1.6;
	uv.x *= 1.5;
	float d = length(uv);
	COLOR = texture(blood, UV);
	COLOR.a *= 1. - smoothstep(d - .25, d, radius);
	COLOR.a = min(.85, COLOR.a);
}
