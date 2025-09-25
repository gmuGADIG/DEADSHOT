class_name Player extends CharacterBody3D

static var instance:Player

const SPEED = 6.5

func _init() -> void:
	instance = self

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement := Vector3(input.x, 0, input.y)
	velocity = movement * SPEED
	
	move_and_slide()
