extends Node2D

func _on_load_save_button_pressed() -> void:
	#Load previous save (Need to incorporate saves for this to work, so it just resets to the intro for now)
	get_tree().change_scene_to_file("res://menu/cutscenes/intro/intro_cutscene.tscn")


func _on_main_menu_button_pressed() -> void:
	#return to main menu
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	#quit game
	get_tree().quit()
