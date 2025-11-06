extends Control
@export var back_button : Button

@onready var bus := AudioServer.get_bus_index("Master")

# Placeholder values btw
@export var music_value := 50
@export var vfx_value := 50

func _ready() -> void:
	%Music.value = music_value
	%VFX.value = vfx_value
	
# 
func _on_music_value_changed(_value: float) -> void:
	music_value = %Music.value
	%MusicPercentage.text = str(music_value) + "%"
	
	

func _on_vfx_value_changed(_value: float) -> void:
	vfx_value = %VFX.value
	%VFXPercentage.text = str(vfx_value) + "%"
	
	
