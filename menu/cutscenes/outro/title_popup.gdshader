shader_type canvas_item;

//programatically change this if you want to, remove the progress based on time.
uniform float progress : hint_range(-1.0,2.0) = 0.0;

//the width of the burn area, higher values makes the burn wider, 1 makes the burn cover the whole sprite
uniform float width : hint_range(0.0,2.0) = .7;

//Noise to sample from for the burning
uniform sampler2D noise;
//speed of the burn
uniform float speed : hint_range(0.0,1.0) = 0.5;

float inverse_lerp(float a, float b, float v){
	return (v-a)/(b-a);
}

void fragment() {
	//Initial Sprite
    vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color;

	//Magic Shader
	float burn_progress = progress;
	float noise_value = texture(noise,UV).x;
	float mask = inverse_lerp(1.0 - burn_progress,(1.0 + width) - burn_progress, 1.0-UV.x);
	float value = 1.0-clamp(mask + noise_value,0.0,1.0);
	COLOR.a = min(value,tex_color.a);
}
