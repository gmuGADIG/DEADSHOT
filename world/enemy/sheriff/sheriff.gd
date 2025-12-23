extends Wilder

@export var star : PackedScene

func attack() -> void:
	while true:
		var rng : int = randi_range(1,100)
		if rng <= 80 :
			await get_tree().create_timer(randf_range(timeBetweenShotsMin,timeBetweenShotsMax), false).timeout
			if process_mode == ProcessMode.PROCESS_MODE_DISABLED: continue
			shootBullet()
		else:
			var old_speed := movement_speed
			movement_speed = 0
			await get_tree().create_timer(1, false).timeout
			if process_mode == ProcessMode.PROCESS_MODE_DISABLED: continue
			shootStar()
			await get_tree().create_timer(2.0, false).timeout
			movement_speed = old_speed

func shootStar() -> void:
	var new_star : = star.instantiate()
	new_star.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_star)
	new_star.fire(self, getPlayerDirection())
