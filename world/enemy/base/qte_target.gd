class_name QTETarget
extends Node3D

@onready var sprite: Sprite3D = %NOT_VISIBLE_IN_GAME

func _ready() -> void:
	sprite.hide()
