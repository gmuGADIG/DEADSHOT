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
