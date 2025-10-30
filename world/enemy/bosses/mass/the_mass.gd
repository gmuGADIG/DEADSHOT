class_name TheMass extends BossEnemy

@export var spike : PackedScene
@export var chunk : PackedScene


func pick_action() -> void:
	if $Health.health > $Health.max_health/2:
		action_player.play(phase_1_action_names.pick_random())
	else:
		action_player.play(phase_2_action_names.pick_random())

func idle() -> void:
	pass

func spike_attack() -> void:
	var new_spike : Spike = spike.instantiate()
	add_sibling(new_spike)
	
func shoot_chunk() -> void:
	var new_chunk : EnemyBullet = chunk.instantiate()
	add_sibling(new_chunk)
	new_chunk.global_position = $BulletSpawnPoint.global_position
	new_chunk.direction = Vector3.BACK.rotated(Vector3.UP,deg_to_rad(randf_range(-100,100)))
