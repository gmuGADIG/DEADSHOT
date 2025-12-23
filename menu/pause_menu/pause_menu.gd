extends Control
var is_paused: bool = false

## A reference to any menu that is instantiated by the pause menu.
var submenu : CanvasItem

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
		if is_paused and submenu and submenu is SkillTree \
				and (submenu as SkillTree).selected_skill_button:
			(submenu as SkillTree).on_skill_unselected()
		elif is_paused and submenu and submenu.visible:
			submenu.queue_free()
		elif is_paused:
			_on_resume_pressed()
		else:
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
		submenu = meat_locker_scene.instantiate()
		add_child(submenu)

func _on_settings_pressed() -> void:
		var options_scene := load("res://menu/options_menu/options_menu.tscn")
		submenu = options_scene.instantiate()
		add_child(submenu)

func _on_restart_pressed() -> void:
		print("Restart to last campfire")

func _on_menu_pressed() -> void:
		get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func _exit_tree() -> void: 
	get_tree().paused = false
