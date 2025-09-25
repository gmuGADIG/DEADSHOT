class_name Player extends CharacterBody3D

const SPEED = 6.5

static var instance : Player

func _ready() -> void:
	print("player ready")
	instance = self

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		Save.save_game()
	
	if event.is_action_pressed("roll"):
		print("Spacec")
		Save.load_game()

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement := Vector3(input.x, 0, input.y)
	velocity = movement * SPEED
	
	move_and_slide()
