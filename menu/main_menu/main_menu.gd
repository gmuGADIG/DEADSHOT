extends Control

func _on_new_save_button_pressed() -> void:
	SceneManager.change_scene_to_file("res://menu/cutscenes/intro/intro_cutscene.tscn")

func _on_load_save_button_pressed() -> void:
	if Save.save_file_exists():
		Save.load_game()
	else:
		_on_new_save_button_pressed()

func _on_options_button_pressed() -> void:
	# TODO: Load Options Menu Scene
	print("Options Opened")

func _on_quit_button_pressed() -> void:
	#Quit Game
	get_tree().quit()
