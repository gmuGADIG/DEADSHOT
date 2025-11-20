extends Control

@export var gunshot: AudioStream
@export var gun_spinning: AudioStream

func _on_new_save_button_pressed() -> void:
	SceneManager.change_scene_to_file("res://menu/cutscenes/intro/intro_cutscene.tscn")

func _on_load_save_button_pressed() -> void:
	await get_tree().create_timer(1.0).timeout
	if Save.save_file_exists():
		Save.load_game()
	else:
		_on_new_save_button_pressed()

func _on_options_button_pressed() -> void:
	await get_tree().create_timer(1.0).timeout
	# TODO: Load Options Menu Scene
	print("Options Opened")

func _on_quit_button_pressed() -> void:
	await get_tree().create_timer(1.0).timeout
	#Quit Game
	get_tree().quit()
	
func _on_button_pressed() -> void:
	$AudioStreamPlayer.stream = gunshot
	$AudioStreamPlayer.play()
	pass # Replace with function body.
	

func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.stream = gun_spinning
	$AudioStreamPlayer.play()
	pass # Replace with function body.

func _on_button_mouse_exited() -> void:
	$AudioStreamPlayer.stop()
	pass # Replace with function body.

func _on_audio_stream_player_finished() -> void:
	if $AudioStreamPlayer.stream != gunshot:
		$AudioStreamPlayer.play()
	pass # Replace with function body.
