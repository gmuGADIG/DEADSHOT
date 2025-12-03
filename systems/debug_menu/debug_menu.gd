extends CanvasLayer

func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu") and OS.is_debug_build():
		visible = not visible


func _on_small_desert_button_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://world/levels/desert_intro/level_desert_intro.tscn")


func _on_mines_button_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://world/levels/mines/level_mines.tscn")


func _on_skill_tree_button_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://menu/skill_tree/skill_tree.tscn")

func _on_prop_demo_button_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://test_scenes/prop_demo.tscn")

func _on_max_ammo_pressed() -> void:
	Player.instance.get_gun().reserve_ammo = 999

func _on_god_mode_pressed() -> void:
	var health := Player.instance.health_component
	health.vulnerable = not health.vulnerable

func _on_clear_save_pressed() -> void:
	DirAccess.remove_absolute(Save.SAVE_FILE)
	get_tree().quit()
