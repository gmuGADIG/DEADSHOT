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
	%UIClickSound.play()

func _on_button_mouse_entered() -> void:
	if not button_pressed:
		%UIHoverSound.play()

func hide_reticles() -> void:
	var reticles := [
		$VBoxContainer/NewSaveButton/Reticle,
		$VBoxContainer/LoadSaveButton/Reticle,
		$VBoxContainer/SettingsButton/Reticle,
		$VBoxContainer/QuitButton/Reticle
	]
	
	for r: TextureRect in reticles:
		r.modulate = Color.TRANSPARENT # the reticle controls its `visible` property, so we have to hide it another way
