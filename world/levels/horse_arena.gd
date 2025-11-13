extends Node3D
@export
var customHealth:= 500

func _ready() -> void:
	$Horse/Health.max_health = customHealth
	$Horse/Health.health = customHealth
