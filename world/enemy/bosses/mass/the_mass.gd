extends BossEnemy

func pick_action() -> void:
	if $Health.health > $Health.max_health/2:
		action_player.play(phase_1_action_names.pick_random())
	else:
		action_player.play(phase_2_action_names.pick_random())

func spike_attack() -> void:
	print("spiker")
