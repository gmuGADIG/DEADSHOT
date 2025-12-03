extends Control
@export var back_button : Button

@onready var music_bus := AudioServer.get_bus_index("Music")
@onready var vfx_bus := AudioServer.get_bus_index("VFX")

# Volumes from 0 to 100
@onready var music_value := db_to_linear(AudioServer.get_bus_volume_db(music_bus)) * 100
@onready var vfx_value := db_to_linear(AudioServer.get_bus_volume_db(vfx_bus)) * 100

func _ready() -> void:
	open()

func open() -> void:
	%Music.value = music_value
	%VFX.value = vfx_value
	
	# Sets text of menu to value of respective buses
	%MusicPercentage.text = str(int(music_value)) + "%"
	%VFXPercentage.text = str(int(vfx_value)) + "%"
	
	$AnimationPlayer.play("open")

func _on_music_value_changed(_value: float) -> void:
	music_value = %Music.value
	%MusicPercentage.text = str(int(music_value)) + "%"
	
	AudioServer.set_bus_volume_linear(music_bus, music_value)
	
func _on_vfx_value_changed(_value: float) -> void:
	vfx_value = %VFX.value
	%VFXPercentage.text = str(int(vfx_value)) + "%"
	
	AudioServer.set_bus_volume_linear(vfx_bus, vfx_value)

func _on_back_button_pressed() -> void:
	$AnimationPlayer.play_backwards("open")
	await $AnimationPlayer.animation_finished
	queue_free()
	
