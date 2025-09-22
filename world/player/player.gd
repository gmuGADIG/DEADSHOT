extends CharacterBody3D

const SPEED = 6.5

func _ready() ->void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement := Vector3(input.x, 0, input.y)
	velocity = movement * SPEED
	
	move_and_slide()
	
func _pause_game() -> void:
	if(Input.is_action_just_pressed("ui_cancel")):
		get_tree().paused = true

func _process(_delta: float) ->void:
	_pause_game()
	
	
