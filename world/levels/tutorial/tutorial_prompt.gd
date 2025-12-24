extends Sprite3D

func _ready() -> void:
	var shader_mat : ShaderMaterial = material_override
	shader_mat.set_shader_parameter("albedo_texture",texture)
	#shader_mat.set_shader_parameter("width",1.5)
