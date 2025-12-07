extends Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_FULLSCREEN
