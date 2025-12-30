extends Area3D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire"):
		var cam := MainCam.instance
		var ray_orig := cam.project_ray_origin(get_viewport().get_mouse_position())
		var ray_norm := cam.project_ray_normal(get_viewport().get_mouse_position())

		var query := PhysicsRayQueryParameters3D.create(
			ray_orig,
			ray_orig + ray_norm * 1000.,
			collision_layer,
		)
		query.collide_with_areas = true
		var result := get_world_3d().direct_space_state.intersect_ray(query)

		if not result.is_empty():
			print("FOOBAR: ", result.collider.get_path())

