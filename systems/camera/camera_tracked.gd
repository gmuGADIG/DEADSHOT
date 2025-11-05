class_name CameraTracked
extends Node3D

@export_range(0, 10) var weight := 1.0
@export var enabled := true:
	set(value):
		enabled = value
		_update_group()

func _ready() -> void:
	_update_group()

func _update_group() -> void:
	if enabled: add_to_group("camera_tracked")
	else: remove_from_group("camera_tracked")
