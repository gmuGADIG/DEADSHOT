class_name TheMass extends BossEnemy

@export_category("Attacks")
@export_subgroup("Spike Field")
@export var spike_field_scene : PackedScene
@export var spike_field_area : CollisionShape3D
@export var spike_field_count : int ## The number of spikes spawned in the fields
@export_subgroup("Rapid Spike")
@export var rapid_spike_scene : PackedScene
@export_subgroup("Chunk")
@export var chunk : PackedScene
@export var chunk_spread_degrees : float

func pick_action() -> void:
	if $Health.health > $Health.max_health/2:
		action_player.play(phase_1_action_names.pick_random())
	else:
		action_player.play(phase_2_action_names.pick_random())

func idle() -> void:
	pass


func spike_field() -> void: ## Summons many spikes at once
	for i in range(spike_field_count):
		var new_spike : Spike = spike_field_scene.instantiate()
		add_sibling(new_spike)
	
func rapid_spike() -> void:
	var new_spike : Spike = rapid_spike_scene.instantiate()
	add_sibling(new_spike)


func shoot_chunk() -> void:
	var new_chunk : EnemyBullet = chunk.instantiate()
	add_sibling(new_chunk)
	new_chunk.global_position = $BulletSpawnPoint.global_position
	new_chunk.set_target(Player.instance.global_position)
	var shoot_angle_rad : float = deg_to_rad(randf_range(-chunk_spread_degrees,chunk_spread_degrees))
	new_chunk.direction = new_chunk.direction.rotated(Vector3.UP,shoot_angle_rad)
