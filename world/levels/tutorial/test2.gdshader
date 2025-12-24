shader_type canvas_item;

//programatically change this if you want to, remove the progress based on time.
uniform float progress : hint_range(-1.0,2.0) = 0.0;
//the width of the burn area, higher values makes the burn wider, 1 makes the burn cover the whole sprite
uniform float width : hint_range(0.0,2.0) = .5;

//Noise to sample from for the burning
uniform sampler2D noise;
//colors to use for the burn color, the progress of the burn goes left to right
uniform sampler2D colorCurve;

//make this timed or not, if not timed, you must programatically set the burn (such as with a lerp)
uniform bool timed = true;
//speed of the burn
uniform float speed : hint_range(0.0,1.0) = 0.5;
//hacky way to make this angled, far from perfect. 1.0 is right to left. 0 is bottom to top. outside
//that range is wierd.
uniform float angle = 1.0;

float inverse_lerp(float a, float b, float v){
	return (v-a)/(b-a);
}

void fragment() {
	float burn_progress;
	if(timed){
		burn_progress = (fract(TIME * speed / 2.0) * 2.0);
	}else{
		burn_progress = progress;
	}
	float noise_value = texture(noise,UV).x;
	float mask = inverse_lerp(1.0 - burn_progress,(1.0 + width) - burn_progress, 1.0-UV.x);
	float value = clamp(mask + noise_value,0.0,1.0);
	vec4 curve_value = texture(colorCurve,vec2(value));
	COLOR = mix(COLOR, curve_value, value);
	COLOR.a = min(texture(TEXTURE,UV).a,COLOR.a);
}