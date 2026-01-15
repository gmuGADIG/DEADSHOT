class_name Level
extends Node3D

enum AmbienceType{
	DESERT,
	CAVE
}

@export var ambience_type : AmbienceType




func _ready() -> void:
	Player.instance.set_ambience(ambience_type)
