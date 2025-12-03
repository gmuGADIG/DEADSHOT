extends Control

@export var gunshot: AudioStream
@export var gun_spinning: AudioStream

var button_pressed : bool = false

func _ready() -> void:
	if not Save.save_file_exists():
		$VBoxContainer/LoadSaveButton.hide()

func _on_new_save_button_pressed() -> void:
	if not button_pressed:
		button_pressed = true
		play_gunshot_sound()
		hide_reticles()
		SceneManager.change_scene_to_file("res://menu/cutscenes/intro/intro_cutscene.tscn")

func _on_load_save_button_pressed() -> void:
	if not button_pressed:
		button_pressed = true
		play_gunshot_sound()
		hide_reticles()
		Save.load_game()

func _on_options_button_pressed() -> void:
	if not button_pressed:
		button_pressed = true
		print("Options Opened")

func _on_quit_button_pressed() -> void:
	if not button_pressed:
		button_pressed = true
		play_gunshot_sound()
		hide_reticles()
		#Quit Game
		SceneManager.quit_game()
	
func play_gunshot_sound() -> void:
	$AudioStreamPlayer.stream = gunshot
	$AudioStreamPlayer.play()
	

func _on_button_mouse_entered() -> void:
	if not button_pressed:
		$AudioStreamPlayer.stream = gun_spinning
		$AudioStreamPlayer.play()

func hide_reticles() -> void:
	$VBoxContainer/NewSaveButton/Reticle.position.x += 500
	$VBoxContainer/LoadSaveButton/Reticle.position.x += 500
	$VBoxContainer/SettingsButton/Reticle.position.x += 500
	$VBoxContainer/QuitButton/Reticle.position.x += 500
