extends Wilder

enum SheriffAttack {
	NORMAL,
	STAR,
	
}
@export var star : PackedScene

func attack() -> void:
	while true:
		var attack_type : SheriffAttack = SheriffAttack.values().pick_random()
		match attack_type:
			SheriffAttack.NORMAL:
				await get_tree().create_timer(randf_range(timeBetweenShotsMin,timeBetweenShotsMax), false).timeout
				if process_mode == ProcessMode.PROCESS_MODE_DISABLED: continue
				shootBullet()
			SheriffAttack.STAR:
				await get_tree().create_timer(randf_range(timeBetweenShotsMin,timeBetweenShotsMax), false).timeout
				if process_mode == ProcessMode.PROCESS_MODE_DISABLED: continue
				shootStar()

func shootStar() -> void:
	var new_star : = star.instantiate()
	new_star.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_star)
	new_star.fire(self, getPlayerDirection())
