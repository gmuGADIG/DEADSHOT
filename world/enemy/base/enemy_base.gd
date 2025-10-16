@abstract
class_name EnemyBase extends CharacterBody3D

#region Enumerations
## Controls what the enemy does when benign.
enum EnemyType {
	## The enemy stays still until the player enters aggro range.
	IDLE,
	## The enemy moves through a set list of points.
	PATROLLING
}

## Controls the current state of the enemy's aggro.
enum AggroState {
	## The enemy has not noticed the player.
	BENIGN,
	## The enemy has detected a player.
	HOSTILE,
	## The enemy is attacking.
	ATTACKING
}
#endregion

#region Variables
## The player in the scene.
@onready var player : Player
@onready var firing_timer: Timer = %FiringTimer

@export_group("Enemy Stats")
## The starting amount of health.
@export var max_hp : float = 10
## The amount of damage done in an attack.
@export var damage : float = 1
## Controls the speed of the enemy agent.
@export var movement_speed : float = 10.0
## Dictates the enemy drops.
@export var drop_item : PackedScene 
# TODO: type is a subclass?
## Does the enemy remain still or move about on their own?
@export var type : EnemyType = EnemyType.IDLE

@export_subgroup("Idle-Only Settings")
## Does the enemy return to their original position after the player leaves?
@export var returns_to_post : bool = true
## The starting position of the enemy.
@export var starting_pos : Vector3

@export_subgroup("Patrol-Only Settings")
## The positions to cycle through when patrolling.
@export var patrol_path : Array[Vector3]
var patrol_index : int = 0

@export_subgroup("Bullet Settings")
@export var fire_rate: float
@export var bullet_speed: float

## Current aggro state of the enemy
var aggro : AggroState = AggroState.BENIGN
## Current distance to the player
var player_distance : float

## The navigation agent.
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D

## The last known global position of the player.
var last_known_player_position : Vector3

## Whether or not the enemy should move, used primarily to stop idle jittering.
var should_move : bool = false
## Whether the enemy was previously tracking, used to scout for the player only
## when the player was tracked and is outside of the range
var was_tracking : bool = false

## How close the enemy is to the destination before being "basically there"
var proximity_tolerance : float = 1

var shooting := false
var can_shoot := true

#endregion

#region Builtin Functions
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	starting_pos = starting_pos if not starting_pos.is_equal_approx(Vector3.ZERO) else position
	last_known_player_position = player.global_position
	%Health.killed.connect(queue_free)

	if fire_rate == 0:
		firing_timer.process_mode = PROCESS_MODE_DISABLED
	else:
		firing_timer.wait_time = fire_rate
		firing_timer.timeout.connect(_on_firing_timer_timeout)
		firing_timer.start()

func _physics_process(_delta: float) -> void:
	match aggro:
		AggroState.BENIGN when type == EnemyType.IDLE:
			idle()
		AggroState.BENIGN when type == EnemyType.PATROLLING:
			patrol()
		AggroState.HOSTILE:
			hostile()
		AggroState.ATTACKING:
			attack()
	
	# Get the position to the next path checkpoint, then point velocity towards
	# the checkpoint.
	if should_move:
		var next_position : Vector3 = navigation_agent.get_next_path_position()
		var direction : Vector3 = global_position.direction_to(next_position)
		velocity = direction * movement_speed
		move_and_slide()
		
## Triggers when enemy is visible
func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	aggro = AggroState.HOSTILE

#endregion

#region Behaviour Functions
## Sets the movement target of this enemy agent.
func set_movement_target(movement_target: Vector3) -> void:
	navigation_agent.target_position = movement_target

## Specifies behaviour during idling phase, when applicable
func idle() -> void:
	was_tracking = false
	
	# if the enemy returns to post,
	if returns_to_post:
		set_movement_target(starting_pos)
		# if the enemy isn't there yet,
		if not is_close_to_destination():
			# the enemy should move.
			should_move = true
		else:
			# else, the enemy should not move.
			should_move = false
	# if the enemy does not return to post,
	else:
		# the enemy should not move.
		should_move = false

## Specifies patrolling behaviour
func patrol() -> void:
	was_tracking = false
	should_move = true
	set_movement_target(patrol_path[patrol_index])
	if is_close_to_destination():
		patrol_index += 1
		patrol_index %= patrol_path.size()

## Finds the player.
@abstract func hostile() -> void

## Attacks the player.
@abstract func attack() -> void

## Returns whether the enemy is close to destination
func is_close_to_destination() -> bool:
	return global_position.distance_to(navigation_agent.target_position) < proximity_tolerance

#endregion

func shoot_bullet() -> void:
	if !can_shoot:
		return
	firing_timer.start()
	if (!shooting):
		var bullet_reference: Node3D = load("res://world/enemy/Enemy Bullets/enemy_bullet.tscn").instantiate()
		add_sibling(bullet_reference)
		bullet_reference.global_position = global_position + Vector3(0, 1, 0)
		bullet_reference.set_speed(bullet_speed)
		bullet_reference.set_target(get_tree().get_first_node_in_group("player").global_position)
		shooting = true

func _on_firing_timer_timeout() -> void:
	shooting = false
	shoot_bullet()

func stop_shooting() -> void:
	can_shoot = false

func spawn_item() -> void: # bare bones of the drop system for right now
	var item_reference : Node3D = drop_item.instantiate()
	item_reference.global_postion = global_position
	add_sibling(item_reference)
