extends Control
@export var back_button : Button

@onready var bus := AudioServer.get_bus_index("Master")
var linear_music := db_to_linear(AudioServer.get_bus_volume_db(bus))

# Placeholder value for vfx
@export var music_value := linear_music * 100
@export var vfx_value := 50


func _ready() -> void:
	%Music.value = music_value
	%VFX.value = vfx_value
	
	%MusicPercentage.text = str(int(music_value)) + "%"
	%VFXPercentage.text = str(int(vfx_value)) + "%"

	# need to change value of sound. uhhhh
	# is there a better way to do the int calling? it looks... ass LOL

func _on_music_value_changed(_value: float) -> void:
	music_value = %Music.value
	%MusicPercentage.text = str(int(music_value)) + "%"
	
	
func _on_vfx_value_changed(_value: float) -> void:
	vfx_value = %VFX.value
	%VFXPercentage.text = str(int(vfx_value)) + "%"
