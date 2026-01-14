class_name Options
extends Control

static var sfx_value : float = 100:
	set(new_val):
		sfx_value = new_val
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), new_val / 100.0)
	
static var music_value :float = 100:
	set(new_val):
		music_value = new_val
		MainMusicPlayer.set_master_loudness(clampf(new_val / 100.0, 0.0, 1.0))

@export var back_button : Button

@onready var music_bus := AudioServer.get_bus_index("Music")
@onready var sfx_bus := AudioServer.get_bus_index("SFX")


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
	OptionsSave.save_options()
	
func _on_sfx_value_changed(_value: float) -> void:
	sfx_value = %SFX.value
	%SFXPercentage.text = str(int(sfx_value)) + "%"

	AudioServer.set_bus_volume_linear(sfx_bus, sfx_value / 100.)
	OptionsSave.save_options()

func _on_back_button_pressed() -> void:
	$AnimationPlayer.play_backwards("open")
	await $AnimationPlayer.animation_finished
	queue_free()
	
