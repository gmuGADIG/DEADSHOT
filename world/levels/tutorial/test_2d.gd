extends Sprite2D

@export var noise : Texture

func _ready() -> void:
	var mat : ShaderMaterial = material
	mat.set_shader_parameter("noise",noise)
