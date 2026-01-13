class_name Wilder
extends EnemyBase

## THE WILDER
## The wilder's a terrifying tanky lunatic with a grenade launcher. They zip around spamming grenade projectiles.


#region Variables

## The amount of time the wilder runs away for before becoming aggro again
@export var run_away_time_min: float = 1.5
@export var run_away_time_max: float = 3
## Select what node this fires as a bullet. It has to be of the Bullet class!
@export var bullet: PackedScene
## The most distance the enemy will travel in a single movement cycle
@export var maxTravelDistance: float = 5.0

var target_position : Vector3
var target_random_walk_cycles : int
var current_random_walk_cycle : int
##Checks if the wilder gets stuck during aggro or patrol mode
var last_position : Vector3
#endregion

#region Behaviour Functions

func _ready() -> void:
	super._ready()
	
	$RunAwayTimer.timeout.connect(func() -> void:
		switch_state(AggroState.HOSTILE)
	)
	switch_state.call_deferred(AggroState.HOSTILE)	


## FIND A NICE POSITION TO RUN TO
func enter_patrol() -> void:
	should_move = true
	pick_flee_target()
	$RunAwayTimer.start(randf_range(run_away_time_min,run_away_time_max))
	
## RUN AWAY randomly,
func patrol() -> void:
	print("patrol")
	var target_dist_squared : float = global_position.distance_squared_to(target_position)
	if is_close_to_destination() or global_position.is_equal_approx(last_position):
		pick_flee_target()
	last_position = global_position

func pick_flee_target() -> void:
	target_position = global_position
	var target_direction : Vector3 = global_position.direction_to(Player.instance.global_position)
	var random_angle : float = PI+randf_range(-PI/2,PI/2)
	target_position += target_direction.rotated(Vector3.UP,random_angle)*3
	
	target_position = NavigationServer3D.map_get_closest_point(
		navigation_agent.get_navigation_map(),target_position
	)
	
	set_movement_target(target_position)

func enter_hostile() -> void:
	should_move = true
	pick_aggro_target()

func hostile() -> void:
	var target_dist_squared : float = global_position.distance_squared_to(target_position)
	
	
	var close_to_player : bool = 100 > global_position.distance_squared_to(Player.instance.global_position)
	if close_to_player:
		switch_state(AggroState.ATTACKING)
		return
	if is_close_to_destination() or global_position.is_equal_approx(last_position):
		pick_aggro_target()
	last_position = global_position
#
func pick_aggro_target() -> void:
	target_position = global_position
	var target_direction : Vector3 = global_position.direction_to(Player.instance.global_position)
	
	var random_angle : float = 0
	target_position += target_direction.rotated(Vector3.UP,random_angle)*3
	
	target_position = NavigationServer3D.map_get_closest_point(
		navigation_agent.get_navigation_map(),target_position
	)
	print("target_dir2",target_position)
	
	set_movement_target(target_position)

func enter_attack() -> void:
	print("Attacking!!")
	should_move = false
	get_tree().create_timer(0.3).timeout.connect(fire_gun)
	
	
## Create a bullet aimed at the player.
func attack() -> void:
	
	return

func fire_gun() -> void:
	var shoot_dir : = getPlayerDirection()
	shoot(shoot_dir)
	await get_tree().create_timer(0.1).timeout
	shoot(shoot_dir)
	await get_tree().create_timer(0.1).timeout
	shoot(shoot_dir)
	await get_tree().create_timer(0.1).timeout
	
	switch_state(AggroState.BENIGN)
func shoot(shoot_dir : Vector3) -> void:
	var newBullet: Bullet = bullet.instantiate()
	newBullet.atk_source = DamageInfo.Source.ENEMY
	add_sibling(newBullet)
	newBullet.fire(self, shoot_dir)
	%WilderShootSound.play()
	

func getPlayerDirection() -> Vector3:
	# We add 1 to the Y value of this vector to keep it aimed at the player's center of mass, not their origin.
	#var rawDirection: Vector3 = player.global_position-self.global_position + Vector3(0,1,0)
	var rawDirection: Vector3 = self.global_position.direction_to(player.global_position + Vector3(0,1,0))
	return rawDirection.normalized()

func _on_killed() -> void:
	var die_sound:AudioStreamPlayer3D = %WilderDeathSound
	die_sound.reparent(get_tree().current_scene)
	die_sound.play()

##INFO: THIS IS IMPORTANT, it overwrites the default behavior of entering agro as soon as it enters the screen
func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass

#endregion


func _on_visibility_changed() -> void:
	if visible:
		switch_state(AggroState.HOSTILE)
