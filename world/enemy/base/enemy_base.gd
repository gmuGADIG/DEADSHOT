extends CharacterBody3D

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
	## The enemy has detected a player within the smell range.
	SCOUTING,
	## The enemy has sighted the player and is actively tracking.
	TRACKING
}
#endregion

#region Variables
## The player in the scene.
@export var player : Node3D

@export_group("Enemy Stats")
## Controls the speed of the enemy agent.
@export var movement_speed : float = 10.0
## The maximum distance at which the enemy will begin tracking the player.
@export var sight_radius : float = 10.0
## The maximum distance at which the enemy will begin scouting for the player
## after having lost them.
@export var smell_radius : float = 15.0
## Does the enemy remain still or move about on their own?
@export var type : EnemyType = EnemyType.IDLE
## The amount of time (seconds) the enemy stays at the last known player 
## position before returning back to what it was doing.
@export var patience : float = 5.0;
var currentPatience : float;

@export_subgroup("Idle-Only Settings")
## Does the enemy return to their original position after the player leaves?
@export var returns_to_post : bool = true;
## The starting position of the enemy.
@export var starting_pos : Vector3;

@export_subgroup("Patrol-Only Settings")
## The positions to cycle through when patrolling.
@export var patrol_path : Array[Vector3];
var patrol_index : int = 0;

## Current aggro state of the enemy
var aggro : AggroState = AggroState.BENIGN;
## Current distance to the player
var player_distance : float;

## The navigation agent.
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D

## The last known position of the player.
var last_known_player_position : Vector3;

## Whether or not the enemy should move, used primarily to stop idle jittering.
var shouldMove : bool = false;
## Whether the enemy was previously tracking, used to scout for the player only
## when the player was tracked and is outside of the range
var wasTracking : bool = false;

## How close the enemy is to the destination before being "basically there"
var proximityTolerance : float = 1;

#endregion

#region Builtin Functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_known_player_position = player.position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	player_distance = global_position.distance_to(player.global_position);
	
	if player_distance <= sight_radius:
		# Player is within sight radius.
		aggro = AggroState.TRACKING;
	elif player_distance <= smell_radius:
		# Player is within smell radius
		if wasTracking:
			aggro = AggroState.SCOUTING;
		else:
			aggro = AggroState.BENIGN;
	else:
		# Player is far away
		aggro = AggroState.BENIGN;
	
	pass

func _physics_process(delta: float) -> void:
	match aggro:
		AggroState.BENIGN when type == EnemyType.IDLE:
			idle();
		AggroState.BENIGN when type == EnemyType.PATROLLING:
			patrol();
		AggroState.SCOUTING:
			scout(delta);
		AggroState.TRACKING:
			track();
	
	# Get the position to the next path checkpoint, then point velocity towards
	# the checkpoint.
	if (shouldMove):
		var next_position : Vector3 = navigation_agent.get_next_path_position()
		var direction : Vector3 = global_position.direction_to(next_position)
		velocity = direction * movement_speed
		move_and_slide()
#endregion

#region Behaviour Functions
## Sets the movement target of this enemy agent.
func set_movement_target(movement_target: Vector3) -> void:
	navigation_agent.target_position = movement_target
	pass

func idle() -> void:
	
	wasTracking = false
		
	# if the enemy returns to post,
	if returns_to_post:
		set_movement_target(starting_pos)
		# if the enemy isn't there yet,
		if (not is_close_to_destination()):
			# the enemy should move.
			shouldMove = true
		else:
			# else, the enemy should not move.
			shouldMove = false
	# if the enemy does not return to post,
	else:
		# the enemy should not move.
		shouldMove = false
	pass

func patrol() -> void:
	## TODO: IMPLEMENT PATROLLING 
	wasTracking = false
	shouldMove = true
	#if global_position.distance_to(patrol_path[patrol_index]) < 
	pass

func scout(delta : float) -> void:
	# The enemy will go to the last place it saw the player.
	set_movement_target(last_known_player_position)
	
	# If it's already there, don't move. Otherwise, move.
	shouldMove = not is_close_to_destination()
	
	# Once the enemy is at the last known player position, it'll linger there
	# for the amount of seconds, set in patience
	if (is_close_to_destination()):
		if currentPatience > 0:
			currentPatience -= delta;
		else:
			wasTracking = false
		pass

## Moves the enemy towards the player.
func track() -> void:
	wasTracking = true
	shouldMove = true
	set_movement_target(player.position)
	last_known_player_position = player.position
	currentPatience = patience
	pass

## Whether the enemy is close to destination
func is_close_to_destination() -> bool:
	return global_position.distance_to(navigation_agent.target_position) < proximityTolerance

#endregion
