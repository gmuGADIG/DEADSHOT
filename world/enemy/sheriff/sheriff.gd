extends Wilder

@export var star : PackedScene
@export var slash : PackedScene

func attack() -> void:
	while true:
		if process_mode == ProcessMode.PROCESS_MODE_DISABLED: continue
		
		var dist_squared := global_position.distance_squared_to(Player.instance.global_position)
		print(dist_squared)
		if dist_squared <= 22:
			var old_speed := movement_speed
			movement_speed = old_speed *0.25
			await get_tree().create_timer(0.5, false).timeout
			do_slash()
			await get_tree().create_timer(0.5, false).timeout
			movement_speed = old_speed
			continue
		
		var rng : int = randi_range(1,100)
		if rng <= 80 :
			await get_tree().create_timer(randf_range(timeBetweenShotsMin,timeBetweenShotsMax), false).timeout
			shootBullet()
		else:
			var old_speed := movement_speed
			movement_speed = 0
			await get_tree().create_timer(1, false).timeout
			shoot_star()
			await get_tree().create_timer(2.0, false).timeout
			movement_speed = old_speed

func shoot_star() -> void:
	var new_star : = star.instantiate()
	new_star.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_star)
	new_star.fire(self, getPlayerDirection())

func do_slash() -> void:
	var new_slash : = slash.instantiate()
	new_slash.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_slash)
	new_slash.fire(self, getPlayerDirection())
	pass
