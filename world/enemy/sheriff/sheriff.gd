class_name Sheriff
extends Wilder

@export var star : PackedScene
@export var slash : PackedScene

func fire() -> void:
	var rng : int = randi_range(1,100)
	if rng <= 50:
		var shoot_dir : = getPlayerDirection()
		shoot(shoot_dir)
		await get_tree().create_timer(0.1).timeout
		shoot(shoot_dir)
		await get_tree().create_timer(0.1).timeout
		shoot(shoot_dir)
		await get_tree().create_timer(0.1).timeout
	else:
		shoot_star()
	switch_state(AggroState.BENIGN)
	
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
