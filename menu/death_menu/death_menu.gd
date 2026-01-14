extends Control

@onready var sfx_bus := AudioServer.get_bus_index("SFX")
@onready var original_sfx_volume : float = AudioServer.get_bus_volume_linear(sfx_bus)

func _ready() -> void:
	Engine.time_scale = 0.2
	print("TIME SCALE: %.1f" % Engine.time_scale)
	# silence SFX temporarily
	var sfx_tween : Tween = create_tween()
	sfx_tween.tween_method(func (volume: float) -> void:
			AudioServer.set_bus_volume_linear(sfx_bus, volume),
		original_sfx_volume, 0, 3)

func reset_audio() -> void:
	AudioServer.set_bus_volume_linear(sfx_bus, original_sfx_volume)

func _on_load_save_button_pressed() -> void:
	reset_audio()
	Save.load_game()

func _on_main_menu_button_pressed() -> void:
	reset_audio()
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func _on_quit_button_pressed() -> void:
	reset_audio()
	get_tree().quit()
