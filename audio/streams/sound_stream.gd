extends AudioStreamPlayer3D

@export var delete_on_finish : bool = true

func _on_finished() -> void:
	if delete_on_finish: queue_free()
