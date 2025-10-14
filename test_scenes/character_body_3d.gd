extends CharacterBody3D

@export var speed := 10.0

func _ready() -> void: print("Welcome!")
func _process(delta: float) -> void: 
	if Input.is_action_just_pressed("fire"):
		shoot()
	
	var input: = Input.get_vector("move_left","move_right", "move_down", "move_up")
	#position.x += 10 * delta * input.x
	#position.z += 10 * delta * input.y
	
	velocity.x = speed * input.x
	velocity.z = speed * input.y
	
	move_and_slide()

func shoot() -> void:
	var bullet: Node3D = preload("res://world/player/bullet.tscn").instantiate()
	bullet.position = position + Vector3.UP * 1.
	get_parent().add_child(bullet)
