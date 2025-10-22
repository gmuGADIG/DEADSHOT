extends Node3D

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse)
	var ray_dir := cam.project_ray_normal(mouse)
	
	# ray_origin + ray_dir * t = (x, y, z)
	# y = 0
	# ray_origin.y + ray_dir.y * t = 0
	# rey_dir.y * t = -ray_origin.y
	# t = -ray_origin.y / ray_dir.y
	var t := -ray_origin.y / ray_dir.y

	global_position = ray_origin + ray_dir * t
