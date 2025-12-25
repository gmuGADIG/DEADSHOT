shader_type spatial;

uniform sampler2D albedo_texture;

void fragment() {
    vec4 tex_color = texture(albedo_texture, UV);
    ALBEDO = tex_color.rgb;
}
