class_name TutorialPopup
extends Sprite3D


var destroying_tutorial : bool = false
var destroy_time : float = -0.3

@onready var shader_mat : ShaderMaterial = material_override

func _ready() -> void:
	shader_mat.set_shader_parameter("albedo_texture",texture)
	#shader_mat.set_shader_parameter("width",1.5)

func _process(delta: float) -> void:
	update_destroy(delta)

func update_destroy(delta: float) -> void:
	if not destroying_tutorial:
		return
	shader_mat.set_shader_parameter("progress",destroy_time)
	destroy_time += delta
	if destroy_time > 2.0:
		hide()
		destroying_tutorial = false
