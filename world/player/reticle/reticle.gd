extends Node3D

@export var solve_height : float = 1

func _process(delta: float) -> void:
	## Get mouse position, clamped to screen size
	var min_bounds:Vector2 = Vector2(0,0)
	var max_bounds:Vector2 = get_viewport().get_visible_rect().size
	var cam := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position().clamp(min_bounds, max_bounds)
	
	## Calculate world position at y = solve_height
	var ray_origin := cam.project_ray_origin(mouse)
	var ray_dir := cam.project_ray_normal(mouse)
	var t := (solve_height-ray_origin.y) / ray_dir.y
	global_position = (ray_origin + ray_dir * t)
	
	## Rotate sprite (visuals only)
	rotation.y += delta * 2.0
