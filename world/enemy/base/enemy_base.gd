extends CharacterBody3D

@export var movement_speed : float = 10.0
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D
@export var player : CharacterBody3D # replace with better option later

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	navigation_agent.target_position = player.position
	var next_position : Vector3 = navigation_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_position)
	velocity = direction * movement_speed
	move_and_slide()
	pass

func navigate() -> void:
	pass
