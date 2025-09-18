extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _button_pressed() -> void:
	#Load Options Menu Scene
	print("Options Opened")
