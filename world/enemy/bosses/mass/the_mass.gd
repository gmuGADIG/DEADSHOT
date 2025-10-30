class_name TheMass extends BossEnemy

@export_category("Spike Attack")
@export var spike : PackedScene
@export var spike_distance_multiplier : float


func pick_action() -> void:
	if $Health.health > $Health.max_health/2:
		action_player.play(phase_1_action_names.pick_random())
	else:
		action_player.play(phase_2_action_names.pick_random())

func idle() -> void:
	pass

func spike_attack() -> void:
	var spike_pos : Vector3 = Player.instance.global_position+Player.instance.velocity*spike_distance_multiplier
	var new_spike : Spike = spike.instantiate()
	add_sibling(new_spike)
	new_spike.global_position = spike_pos
