extends CharacterBody3D

## Controls the speed of the enemy agent.
@export var movement_speed : float = 10.0
@export var player : CharacterBody3D # replace with better option later

@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D

# TODO: Facilitate different modes of movement, such as patrolling.
# Refer to the GDD for all possible modes of movement.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	# TODO: figure out whether or not it's computationally worth it to set the
	# target every physics frame.
	
	# Get the position to the next path checkpoint, then point velocity towards
	# the checkpoint.
	var next_position : Vector3 = navigation_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_position)
	velocity = direction * movement_speed
	
	move_and_slide()
	pass

## Sets the movement target of this enemy agent.
func set_movement_target(movement_target: Vector3) -> void:
	navigation_agent.target_position = movement_target
	pass

func navigate() -> void:
	pass
