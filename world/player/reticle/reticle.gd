extends Node3D

@export var solve_height : float = 1

func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse)
	var ray_dir := cam.project_ray_normal(mouse)
	
	# ray_origin + ray_dir * t = (x, y, z)
	# y = 1
	# ray_origin.y + ray_dir.y * t = solve_height
	# rey_dir.y * t = solve_height-ray_origin.y
	# t = -ray_origin.y / ray_dir.y
	var t := (solve_height-ray_origin.y) / ray_dir.y

	global_position = ray_origin + ray_dir * t
