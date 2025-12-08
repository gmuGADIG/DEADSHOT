class_name TheMass extends BossEnemy

@export var blood_explosion_scene : PackedScene
@export var arena_area : ArenaArea
@export_category("Attacks")
@export_subgroup("Spikes (General)")
@export var spike_scene : PackedScene
@export var player_still_spread_distance : float = 15 ## Used by spike field, and rapid spike when the player is not moving
@export var player_predict_distance_min : float = -3 ## Used By rapid spike, places the spike between player_predict_distance_min and player_predict_distance_max units away from the player
@export var player_predict_distance_max : float = 15 ## Used By rapid spike, places the spike between player_predict_distance_min and player_predict_distance_max units away from the player
@export var player_predict_spread_angle_deg : float = 90 ## Used by rapid spike, The angle of spread from the player's walking direction the spike should be placed
@export_subgroup("Spike Field")
@export var spike_field_count : int ## The number of spikes spawned in the fields
@export_subgroup("Chunk")
@export var chunk : PackedScene
@export var chunk_spread_degrees : float
@export_subgroup("Spawn Enemy")
@export var enemy_spawn_dist_min : float = 8 ## Distance away from the player the enemy is allowed to spawn
@export var enemy_spawn_dist_max : float = 18 ## Distance away from the player the enemy is allowed to spawn

var phase : int = 1
var spike_spin_direction : int = 0
var spike_spin_angle : int

func _ready() -> void:
	super._ready()
	$%Health.damaged.connect(func() -> void:
		if phase == 1 && $Health.health <= $Health.max_health/2:
			$FakeChunk.hide()
			$ActionPlayer.play("phase_change")
			phase = 2
	)
	#Player.instance.player_state_changed.connect(func() -> void:
		#if 	Player.instance.current_state == Player.PlayerState.ROLLING:
			#_on_player_dash()
	#)

func _process(delta: float) -> void:
	global_position.y = 0.0

func pick_action() -> void:
	var new_action : StringName = last_action
	##HACK again, mildly inoptimal while loop
	while new_action == last_action:
		if phase == 1:
			new_action = phase_1_action_names.pick_random()
		else:
			new_action = phase_2_action_names.pick_random()
	action_player.play(new_action)
	
func idle() -> void:
	pass


func spike_field(delay : float = -1) -> void: ## Summons many spikes at once
	var player_position : Vector3 = Player.instance.global_position
	for i in range(spike_field_count):
		var spike_position : Vector3 = player_position + neutral_spread(0,player_still_spread_distance)
		##Check if outside the boss arena
		if not arena_area.is_point_in_arena(spike_position):
			continue
			
		var new_spike : Spike = spike_scene.instantiate()
		add_sibling(new_spike)
		new_spike.global_position = spike_position
		
		if delay >=0:
			new_spike.delay = delay
		new_spike.prime()
		
	
func rapid_spike(delay : float = -1) -> void:
	var player_position : Vector3 = Player.instance.global_position
	var spike_position : Vector3 = player_position + player_predict_spread()
	##Check if outside the boss arena
	if not arena_area.is_point_in_arena(spike_position):
		return
		
	var new_spike : Spike = spike_scene.instantiate()
	add_sibling(new_spike)
	new_spike.global_position = spike_position
	
	if delay >=0:
		new_spike.delay = delay
	new_spike.prime()

func neutral_spread(min_dist : float, max_dist : float) -> Vector3:
	var result : Vector3 = Vector3.RIGHT
	var angle : float = randf_range(0,360)
	var distance_multiplier : float = randf_range(min_dist,max_dist)
	
	return result.rotated(Vector3.UP,deg_to_rad(angle))*distance_multiplier

func player_predict_spread() -> Vector3:
	var player_velocity : Vector3 = Player.instance.velocity.normalized()
	
	if player_velocity == Vector3.ZERO:
		return neutral_spread(0,player_still_spread_distance)
	var result : Vector3 = player_velocity
	
	var angle : float = randf_range(-player_predict_spread_angle_deg/2.0,player_predict_spread_angle_deg/2.0)
	var distance_multiplier : float = randf_range(player_predict_distance_min,player_predict_distance_max)
	return result.rotated(Vector3.UP,deg_to_rad(angle))*distance_multiplier
	

func spit_enemy() -> void:
	var player_position : Vector3 = Player.instance.global_position
	var target : Vector3 = player_position+neutral_spread(enemy_spawn_dist_min,enemy_spawn_dist_max)
	##HACK: This is mildly inoptimal but I don't care
	while not arena_area.is_point_in_arena(target):
		target = player_position+neutral_spread(enemy_spawn_dist_min,enemy_spawn_dist_max)
	$EnemySpitter.spit_enemy(target)

func teleport_to_center() -> void:
	var new_loc : Vector3 = arena_area.global_position
	new_loc.y = self.global_position.y
	self.global_position = new_loc

func set_up_spike_spin() -> void:
	spike_spin_direction = randi_range(0,1)
	if spike_spin_direction == 0:
		spike_spin_direction = -1
	
	spike_spin_angle = 0

func shoot_spike_spin() -> void:
	var spike_dir : Vector3 = Vector3.BACK.rotated(Vector3.UP,deg_to_rad(spike_spin_angle))
	
	for i in range(0,20,2):
		var spike_position : Vector3 = global_position+spike_dir*i
		##Check if outside the boss arena
		if not arena_area.is_point_in_arena(spike_position):
			continue
		
		var new_spike : Spike = spike_scene.instantiate()
		add_sibling(new_spike)
		new_spike.global_position = spike_position
		new_spike.delay = 1
		new_spike.prime()
	
	spike_spin_angle+=spike_spin_direction*15
	
#BUG: uses EnemyBullet but EnemyBullet has been refactored out
func shoot_chunk() -> void:
	
	var new_chunk : Bullet = chunk.instantiate()
	add_sibling(new_chunk)
	new_chunk.global_position = $BulletSpawnPoint.global_position
	var target : Vector3 = Player.instance.global_position
	target += 0.05*Player.instance.velocity*global_position.distance_to(Player.instance.global_position)
	new_chunk.set_target(target)
	#var shoot_angle_rad : float = deg_to_rad(randf_range(-schunk_spread_degrees))
	#new_chunk.direction = new_chunk.direction.rotated(Vector3.UP,shoot_angle_rad)

func death() -> void:
	var blood_explosion : GPUParticles3D = blood_explosion_scene.instantiate()
	add_sibling(blood_explosion)
	blood_explosion.global_position = $BulletSpawnPoint.global_position
	blood_explosion.emitting = true
	super.death()
