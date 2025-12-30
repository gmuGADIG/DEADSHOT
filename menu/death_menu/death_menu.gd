extends Control

func _on_load_save_button_pressed() -> void:
	Save.load_game()

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
