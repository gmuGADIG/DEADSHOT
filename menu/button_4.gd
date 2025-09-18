extends Button

func _ready() -> void:
	#Give button access to this function
	self.pressed.connect(_button_pressed)

func _button_pressed() -> void:
	#print a bye and quit using tree
	print("bye bye")
	get_tree().quit()
