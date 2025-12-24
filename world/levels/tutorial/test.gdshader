shader_type spatial;
uniform sampler2D albedo_texture;

void fragment() {
	//Initial Sprite
    vec4 tex_color = texture(albedo_texture, UV);
    ALBEDO = tex_color.rgb;
	ALPHA = tex_color.a;

	//Magic Shader
}
