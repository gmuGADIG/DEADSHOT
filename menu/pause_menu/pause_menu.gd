extends Control
var is_paused: bool = false

@export var resume_button: Button
@export var locker_button: Button
@export var settings_button: Button
@export var restart_button: Button
@export var menu_button: Button
@export var quit_button: Button

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	locker_button.pressed.connect(_on_locker_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

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
		get_tree().paused = false
		hide()

func _on_locker_pressed() -> void:
		#Load Meat Locker
		var meat_locker_scene := load("res://menu/skill_tree/skill_tree.tscn")
		add_child(meat_locker_scene.instantiate())

func _on_settings_pressed() -> void:
		var options_scene := load("res://menu/options_menu/options_menu.tscn")
		add_child(options_scene.instantiate())

func _on_restart_pressed() -> void:
		print("Restart to last campfire")

func _on_menu_pressed() -> void:
		get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func _exit_tree() -> void: 
	get_tree().paused = false
