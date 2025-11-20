extends Gun

@export var number_of_shots := 5
@export_custom(PROPERTY_HINT_NONE, "suffix:rotations") var spread := .25

func fire() -> void:
	var delta_rads := (TAU * spread) / number_of_shots
	var start := -TAU * spread / 2
	for i in range(number_of_shots):
		var rads := start + delta_rads * i
		var bullet : Bullet
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.fire(
			self, 
			Player.instance.aim_dir().rotated(Vector3.UP, rads)
		)
	
	chamber_ammo -= 1
