extends TextureRect

@export var rotation_speed : float
var button : Button

func _ready() -> void:
	button = get_parent()
	button.mouse_entered.connect(func() -> void:
		if not SceneManager.in_transition():
			show()
	)
	button.mouse_exited.connect(func() -> void:
		if not SceneManager.in_transition():
			hide()
	)

func _process(delta: float) -> void:
	rotation_degrees += rotation_speed*delta
	if rotation_degrees > 360:
		rotation_degrees -= 360
