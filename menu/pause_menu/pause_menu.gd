extends Control
var is_paused: bool = false

@export var resume_button: TextureButton
@export var locker_button: TextureButton
@export var options_button: TextureButton
@export var restart_button: TextureButton
@export var menu_button: TextureButton
@export var quit_button: TextureButton



## Has the player hit the quit button once since they last paused? Used to safeguard against accidental closing.
var already_tried_to_quit: bool = false
## See above, but for the close button.
#var already_tried_to_close: bool = false

## We store the Button.text for Quit and Close. That's because we change the button text to warn the player.
## This way you can edit the button text in the inspector without having to edit the code to make it consistent.
var _initial_quit_button_text: String
#var _initial_close_button_text: String


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	locker_button.pressed.connect(_on_locker_pressed)
	options_button.pressed.connect(_on_options_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	#close_button.pressed.connect(_on_close_pressed)
	
	_initial_quit_button_text = quit_button.get_child(0).text
	#_initial_close_button_text = close_button.text
	
	hide()
	

func _process(_delta: float) -> void:
	#Makes ESC key toggle pause menu visibility
	if(Input.is_action_just_pressed("ui_cancel")):
		print("PAUSED")
		match is_paused:
			true:
				_on_resume_pressed()
			false:
				get_tree().paused = true
				is_paused = true
				show()


func _on_resume_pressed() -> void:
		is_paused = false
		reset_quit_safety()
		#reset_close_safety()
		get_tree().paused = false
		hide()

func _on_locker_pressed() -> void:
		reset_quit_safety()
		#Load Meat Locker
		var meat_locker_scene := load("res://test_scenes/example_scene.tscn")
		add_child(meat_locker_scene.instantiate())


func _on_options_pressed() -> void:
		reset_quit_safety()
		#reset_close_safety()
		print("Enter Options Menu")

func _on_restart_pressed() -> void:
		reset_quit_safety()
		print("Restart to last campfire")

func _on_menu_pressed() -> void:
		reset_quit_safety()
		get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")
	
func _on_quit_pressed() -> void:
		# Reset the opposite button's safety, for aesthetics and safety.
		#reset_close_safety()
		
		if already_tried_to_quit: 
			print("Returning to Main Menu...")
			get_tree().quit()
		else: 
			quit_button.get_child(0).text = "Are you sure?\nGame will not save."
			already_tried_to_quit=true

	
"""func _on_close_pressed() -> void:
		# Reset the opposite button's safety, for aesthetics and safety.
		reset_quit_safety()
		
		if already_tried_to_close:
			print("Quitting to Desktop...")
			get_tree().quit()
		else: 
			close_button.text = "Are you sure? Game will not save."
			already_tried_to_close=true
"""


## These two are called to reset button labels and force players to go through safety checks every time before quit/close.
func reset_quit_safety() -> void:
	#Resetting safety boolean.
	already_tried_to_quit = false
	#Resetting button label.
	quit_button.get_child(0).text = _initial_quit_button_text

"""
func reset_close_safety() -> void:
	#Resetting safety boolean.
	already_tried_to_close = false
	#Resetting button label.
	close_button.text = _initial_close_button_text

func _on_save_button_pressed() -> void:
	_on_resume_pressed()
	Save.save_game()

func _on_load_button_pressed() -> void:
	_on_resume_pressed()
	Save.load_game()
"""
