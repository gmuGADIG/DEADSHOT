extends Node2D

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	var p_world := Player.instance.global_position
	var p_screen := cam.unproject_position(p_world)
	
	position = p_screen
