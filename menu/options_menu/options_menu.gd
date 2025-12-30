extends Control
@export var back_button : Button

@onready var music_bus := AudioServer.get_bus_index("Music")
@onready var sfx_bus := AudioServer.get_bus_index("SFX")

# Volumes from 0 to 100
@onready var sfx_value := db_to_linear(AudioServer.get_bus_volume_db(sfx_bus)) * 100
@onready var music_value := MainMusicPlayer.get_master_loudness() * 100.0

func _ready() -> void:
	open()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_on_back_button_pressed()


func open() -> void:
	%Music.value = music_value
	%SFX.value = sfx_value
	# Sets text of menu to value of respective buses
	%MusicPercentage.text = str(int(music_value)) + "%"
	%SFXPercentage.text = str(int(sfx_value)) + "%"
	$AnimationPlayer.play("open")

func _on_music_value_changed(_value: float) -> void:
	music_value = %Music.value
	%MusicPercentage.text = str(int(music_value)) + "%"

	var perceived := clampf(music_value / 100.0, 0.0, 1.0)
	MainMusicPlayer.set_master_loudness(perceived)
	
func _on_sfx_value_changed(_value: float) -> void:
	sfx_value = %SFX.value
	%SFXPercentage.text = str(int(sfx_value)) + "%"

	AudioServer.set_bus_volume_linear(sfx_bus, sfx_value)

func _on_back_button_pressed() -> void:
	$AnimationPlayer.play_backwards("open")
	await $AnimationPlayer.animation_finished
	queue_free()
	
