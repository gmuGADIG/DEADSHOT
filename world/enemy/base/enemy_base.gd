extends CharacterBody3D

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

## Controls the speed of the enemy agent.
@export var movement_speed : float = 10.0

## The player in the scene.
@export var player : Node3D # replace with better option later

## The maximum distance at which the enemy will begin tracking the player.
@export var sight_radius : float = 10.0

## The maximum distance at which the enemy will begin scouting for the player.
@export var smell_radius : float = 15.0

## Does the enemy remain still or move about on their own?
@export var type : EnemyType = EnemyType.IDLE;
var aggro : AggroState = AggroState.BENIGN;
var player_distance : float;

@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D

# TODO: Facilitate different modes of movement, such as patrolling.
# Refer to the GDD for all possible modes of movement.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	player_distance = global_position.distance_to(player.global_position);
	if player_distance > smell_radius:
		# Player is far away
		aggro = AggroState.BENIGN;
	elif player_distance > sight_radius:
		# Player is within smell radius
		aggro = AggroState.SCOUTING;
	else:
		# Player is within sight radius
		aggro = AggroState.TRACKING;
	pass

func _physics_process(_delta: float) -> void:
	match aggro:
		AggroState.BENIGN when type == EnemyType.IDLE:
			idle();
		AggroState.BENIGN when type == EnemyType.PATROLLING:
			patrol();
		AggroState.SCOUTING:
			scout();
		AggroState.TRACKING:
			track();

## Sets the movement target of this enemy agent.
func set_movement_target(movement_target: Vector3) -> void:
	navigation_agent.target_position = movement_target
	pass

func idle() -> void:
	pass

func patrol() -> void:
	pass

func scout() -> void:
	pass

## Moves the enemy towards the player.
func track() -> void:
	# TODO: figure out whether or not it's computationally worth it to set the
	# target every physics frame.
	set_movement_target(player.position)
	# Get the position to the next path checkpoint, then point velocity towards
	# the checkpoint.
	var next_position : Vector3 = navigation_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_position)
	velocity = direction * movement_speed
	move_and_slide()
	pass
