extends Gun

@export var number_of_shots_fired := 5
@export_custom(PROPERTY_HINT_NONE, "suffix:rotations") var spread := .15

func fire() -> void:
	var delta_rads := (TAU * spread) / number_of_shots_fired
	var start := -TAU * spread / 2
	for i in range(number_of_shots_fired):
		var rads := start + delta_rads * i
		var bullet : Bullet = get_bullet_scene().instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.fire(
			self, 
			Player.instance.aim_dir().rotated(Vector3.UP, rads)
		)
	
	chamber_ammo -= 1
