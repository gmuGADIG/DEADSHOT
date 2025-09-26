extends Control

func _on_new_save_button_pressed() -> void:
	#Load New Save
	print("New Save Loaded")
	get_tree().change_scene_to_file("res://test_scenes/example_scene.tscn")

func _on_load_save_button_pressed() -> void:
	#Load Save
	print("Save Loaded")

func _on_options_button_pressed() -> void:
	#Load Options Menu Scene
	print("Options Opened")

func _on_quit_button_pressed() -> void:
	#Quit Game
	print("Game Quit")
	get_tree().quit()
