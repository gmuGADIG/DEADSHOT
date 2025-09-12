extends CharacterBody3D

const SPEED := 10.0

func _ready() -> void:
	print("Hello, world!")

func _process(delta: float) -> void:
	# if the shoot button was pressed this frame:
	#    shoot()
	if Input.is_action_just_pressed("fire"):
		shoot()
	
	# Get player's input
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Move the player
	velocity = Vector3(input.x, 0, input.y) * SPEED
	move_and_slide()

func shoot() -> void:
	var bullet: Area3D = load("res://world/player/bullet/bullet.tscn").instantiate()
	add_sibling(bullet)
	bullet.global_position = global_position
